#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

function reqEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing env: ${name}`);
  return v;
}

function b64url(input) {
  return Buffer.from(input)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/g, '');
}

async function getAccessToken() {
  const body = new URLSearchParams({
    client_id: reqEnv('GMAIL_CLIENT_ID'),
    client_secret: reqEnv('GMAIL_CLIENT_SECRET'),
    refresh_token: reqEnv('GMAIL_REFRESH_TOKEN'),
    grant_type: 'refresh_token',
  });

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!res.ok) throw new Error(`Token error: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token;
}

function detectMime(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === '.pdf') return 'application/pdf';
  if (ext === '.txt' || ext === '.md') return 'text/plain';
  return 'application/octet-stream';
}

async function sendMail({ to, subject, text, files }) {
  const from = reqEnv('GMAIL_SENDER');
  const accessToken = await getAccessToken();
  const boundary = '----=_Part_Tormenta_' + Date.now();

  const lines = [
    `From: ${from}`,
    `To: ${to}`,
    `Subject: ${subject}`,
    'MIME-Version: 1.0',
    `Content-Type: multipart/mixed; boundary="${boundary}"`,
    '',
    `--${boundary}`,
    'Content-Type: text/plain; charset="UTF-8"',
    'Content-Transfer-Encoding: 7bit',
    '',
    text,
    '',
  ];

  for (const filePath of files) {
    const filename = path.basename(filePath);
    const mimeType = detectMime(filePath);
    const fileData = fs.readFileSync(filePath).toString('base64');

    lines.push(
      `--${boundary}`,
      `Content-Type: ${mimeType}; name="${filename}"`,
      'Content-Transfer-Encoding: base64',
      `Content-Disposition: attachment; filename="${filename}"`,
      '',
      fileData,
      ''
    );
  }

  lines.push(`--${boundary}--`, '');

  const raw = b64url(lines.join('\r\n'));

  const res = await fetch('https://gmail.googleapis.com/gmail/v1/users/me/messages/send', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ raw }),
  });

  if (!res.ok) throw new Error(`Send error: ${res.status} ${await res.text()}`);
  return res.json();
}

async function main() {
  const [, , to, subject, filesCsv, ...bodyParts] = process.argv;
  if (!to || !subject || !filesCsv) {
    console.error('Usage: node send-gmail-attachments.js <to> <subject> <file1,file2,...> [body]');
    process.exit(1);
  }

  const files = filesCsv.split(',').map(s => s.trim()).filter(Boolean);
  if (!files.length) {
    console.error('No attachments provided');
    process.exit(1);
  }

  for (const f of files) {
    if (!fs.existsSync(f)) {
      console.error(`Attachment not found: ${f}`);
      process.exit(1);
    }
  }

  const text = bodyParts.length
    ? bodyParts.join(' ')
    : 'Adjunto documentos solicitados.\n\nCreado por Tormenta.';

  const result = await sendMail({ to, subject, text, files });
  console.log(JSON.stringify({ ok: true, id: result.id, threadId: result.threadId }, null, 2));
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
