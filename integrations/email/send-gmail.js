#!/usr/bin/env node
const fs = require('fs');

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
  const client_id = reqEnv('GMAIL_CLIENT_ID');
  const client_secret = reqEnv('GMAIL_CLIENT_SECRET');
  const refresh_token = reqEnv('GMAIL_REFRESH_TOKEN');

  const body = new URLSearchParams({
    client_id,
    client_secret,
    refresh_token,
    grant_type: 'refresh_token',
  });

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });

  if (!res.ok) {
    throw new Error(`Token error: ${res.status} ${await res.text()}`);
  }

  const json = await res.json();
  return json.access_token;
}

async function sendEmail({ to, subject, text }) {
  const from = reqEnv('GMAIL_SENDER');
  const accessToken = await getAccessToken();

  const mime = [
    `From: ${from}`,
    `To: ${to}`,
    `Subject: ${subject}`,
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset="UTF-8"',
    '',
    text,
  ].join('\r\n');

  const raw = b64url(mime);

  const res = await fetch('https://gmail.googleapis.com/gmail/v1/users/me/messages/send', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ raw }),
  });

  if (!res.ok) {
    throw new Error(`Send error: ${res.status} ${await res.text()}`);
  }

  return res.json();
}

async function main() {
  const [, , to, subject, ...rest] = process.argv;
  if (!to || !subject || !rest.length) {
    console.error('Usage: node send-gmail.js <to> <subject> <body>');
    process.exit(1);
  }
  const text = rest.join(' ');
  const result = await sendEmail({ to, subject, text });
  console.log(JSON.stringify({ ok: true, id: result.id, threadId: result.threadId }, null, 2));
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
