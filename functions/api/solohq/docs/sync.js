import {
  decryptGoogleRefreshToken,
  ensureGoogleDocsTables,
  getSoloUser,
  noStore,
  unauthorized
} from "../_lib.js";
import { json } from "../../../_lib.js";

const DRIVE_SCOPE = "https://www.googleapis.com/auth/drive.file";
const FOLDER_MIME = "application/vnd.google-apps.folder";

function apiError(error, status = 502) {
  return noStore(json({ ok: false, error }, status));
}

async function googleFetch(url, accessToken, options = {}) {
  const headers = new Headers(options.headers || {});
  headers.set("Authorization", `Bearer ${accessToken}`);
  if (options.body && !headers.has("Content-Type")) headers.set("Content-Type", "application/json");
  return fetch(url, { ...options, headers });
}

async function accessTokenForUser(env, credential) {
  const refreshToken = await decryptGoogleRefreshToken(credential.refresh_token_ciphertext, env);
  if (!refreshToken) return { error: "docs_reconnect_required" };
  const body = new URLSearchParams({
    client_id: env.GOOGLE_CLIENT_ID,
    client_secret: env.GOOGLE_CLIENT_SECRET,
    refresh_token: refreshToken,
    grant_type: "refresh_token"
  });
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body
  });
  if (!response.ok) return { error: "docs_reconnect_required" };
  const token = await response.json();
  return token.access_token ? { accessToken: token.access_token } : { error: "docs_reconnect_required" };
}

function projectDocumentContent(project) {
  const status = String(project.status || "developing");
  const progress = Math.max(0, Math.min(100, Number(project.progress) || 0));
  const hours = Math.max(0, Number(project.hours) || 0);
  const updatedAt = Number(project.lastUpdated) ? new Date(Number(project.lastUpdated)).toISOString() : new Date().toISOString();
  const links = Object.entries(project.links && typeof project.links === "object" ? project.links : {})
    .filter(([key, value]) => key !== "docs" && typeof value === "string" && value.trim())
    .map(([key, value]) => `- ${key}: ${value.trim()}`)
    .join("\n");
  return [
    project.name,
    "",
    "SoloHQ project note",
    `Status: ${status}`,
    `Progress: ${progress}%`,
    `Tracked hours: ${hours}`,
    `Last updated in SoloHQ: ${updatedAt}`,
    "",
    "Project memo",
    String(project.memo || "").trim() || "No memo yet.",
    ...(links ? ["", "Project links", links] : []),
    "",
    "This document is managed by SoloHQ. Edits made here may be replaced at the next SoloHQ sync."
  ].join("\n");
}

async function createFolder(accessToken) {
  const response = await googleFetch("https://www.googleapis.com/drive/v3/files?fields=id", accessToken, {
    method: "POST",
    body: JSON.stringify({ name: "SoloHQ", mimeType: FOLDER_MIME })
  });
  if (!response.ok) return null;
  const folder = await response.json();
  return folder.id || null;
}

async function createDocument(accessToken, title) {
  const response = await googleFetch("https://docs.googleapis.com/v1/documents", accessToken, {
    method: "POST",
    body: JSON.stringify({ title })
  });
  if (!response.ok) return null;
  const document = await response.json();
  return document.documentId || null;
}

async function moveToFolder(accessToken, documentId, folderId) {
  const response = await googleFetch(
    `https://www.googleapis.com/drive/v3/files/${encodeURIComponent(documentId)}?addParents=${encodeURIComponent(folderId)}&fields=id`,
    accessToken,
    { method: "PATCH", body: JSON.stringify({}) }
  );
  return response.ok;
}

async function documentEndIndex(accessToken, documentId) {
  const response = await googleFetch(`https://docs.googleapis.com/v1/documents/${encodeURIComponent(documentId)}`, accessToken);
  if (!response.ok) return null;
  const document = await response.json();
  const content = document?.body?.content;
  const finalElement = Array.isArray(content) ? content[content.length - 1] : null;
  return Math.max(1, Number(finalElement?.endIndex || 1) - 1);
}

async function replaceDocumentContent(accessToken, documentId, content) {
  const endIndex = await documentEndIndex(accessToken, documentId);
  if (endIndex === null) return false;
  const requests = [];
  if (endIndex > 1) requests.push({ deleteContentRange: { range: { startIndex: 1, endIndex } } });
  requests.push({ insertText: { location: { index: 1 }, text: content } });
  const response = await googleFetch(`https://docs.googleapis.com/v1/documents/${encodeURIComponent(documentId)}:batchUpdate`, accessToken, {
    method: "POST",
    body: JSON.stringify({ requests })
  });
  return response.ok;
}

async function renameDocument(accessToken, documentId, name) {
  const response = await googleFetch(
    `https://www.googleapis.com/drive/v3/files/${encodeURIComponent(documentId)}?fields=id,name`,
    accessToken,
    { method: "PATCH", body: JSON.stringify({ name }) }
  );
  return response.ok;
}

export async function onRequest(context) {
  const { request, env } = context;
  if (request.method !== "POST") return apiError("method_not_allowed", 405);
  const user = await getSoloUser(request, env);
  if (!user) return noStore(unauthorized());
  if (!env.DB || !env.GOOGLE_CLIENT_ID || !env.GOOGLE_CLIENT_SECRET || !env.SOLOHQ_TOKEN_ENCRYPTION_KEY) {
    return apiError("docs_not_configured", 503);
  }
  let body;
  try { body = await request.json(); } catch { return apiError("invalid_json", 400); }
  const project = body?.project;
  if (!project || typeof project !== "object" || Array.isArray(project) || !String(project.id || "").trim() || !String(project.name || "").trim()) {
    return apiError("invalid_project", 400);
  }
  const projectId = String(project.id).slice(0, 128);
  const projectName = String(project.name).trim().slice(0, 240);
  if (!projectName) return apiError("invalid_project", 400);

  await ensureGoogleDocsTables(env.DB);
  const credential = await env.DB.prepare("SELECT refresh_token_ciphertext, folder_id FROM solohq_google_docs_credentials WHERE user_id = ?").bind(user.sub).first();
  if (!credential) return apiError("docs_not_connected", 428);
  const tokenResult = await accessTokenForUser(env, credential);
  if (!tokenResult.accessToken) return apiError(tokenResult.error, 401);
  const accessToken = tokenResult.accessToken;

  let folderId = String(credential.folder_id || "");
  if (!folderId) {
    folderId = await createFolder(accessToken);
    if (!folderId) return apiError("docs_folder_failed");
    await env.DB.prepare("UPDATE solohq_google_docs_credentials SET folder_id = ?, updated_at = ? WHERE user_id = ?")
      .bind(folderId, new Date().toISOString(), user.sub).run();
  }

  const mapping = await env.DB.prepare("SELECT document_id, document_url FROM solohq_google_docs_projects WHERE user_id = ? AND project_id = ?")
    .bind(user.sub, projectId).first();
  let documentId = mapping?.document_id || "";
  if (!documentId) {
    documentId = await createDocument(accessToken, projectName);
    if (!documentId || !(await moveToFolder(accessToken, documentId, folderId))) return apiError("docs_create_failed");
  } else if (!(await renameDocument(accessToken, documentId, projectName))) {
    return apiError("docs_update_failed");
  }

  if (!(await replaceDocumentContent(accessToken, documentId, projectDocumentContent({ ...project, name: projectName })))) {
    return apiError("docs_update_failed");
  }
  const documentUrl = `https://docs.google.com/document/d/${encodeURIComponent(documentId)}/edit`;
  const now = new Date().toISOString();
  await env.DB.prepare(
    `INSERT INTO solohq_google_docs_projects (user_id, project_id, document_id, document_url, updated_at)
     VALUES (?, ?, ?, ?, ?)
     ON CONFLICT(user_id, project_id) DO UPDATE SET document_id = excluded.document_id, document_url = excluded.document_url, updated_at = excluded.updated_at`
  ).bind(user.sub, projectId, documentId, documentUrl, now).run();
  return noStore(json({ ok: true, documentUrl, updatedAt: now, scope: DRIVE_SCOPE }));
}
