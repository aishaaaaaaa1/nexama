'use strict';

const nodemailer = require('nodemailer');

// ─── Transporter ───────────────────────────────────────────────────────────────
const transporter = nodemailer.createTransport({
  host:   process.env.SMTP_HOST   || 'smtp.gmail.com',
  port:   parseInt(process.env.SMTP_PORT || '587', 10),
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// ─── HTML Template ─────────────────────────────────────────────────────────────
function buildVerificationHtml(nom, verifyUrl) {
  return `
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Confirmez votre compte NexaMa</title>
  <style>
    body { margin:0; padding:0; background:#f4f6f9; font-family:'Segoe UI',Arial,sans-serif; }
    .wrapper { max-width:600px; margin:40px auto; background:#ffffff; border-radius:16px;
               box-shadow:0 4px 24px rgba(0,0,0,0.08); overflow:hidden; }
    .header  { background:linear-gradient(135deg,#0B2341 0%,#1a3a5c 100%);
               padding:40px 32px; text-align:center; }
    .logo    { font-size:32px; font-weight:800; color:#fff; letter-spacing:-1px; }
    .logo span { color:#2ECC71; }
    .body    { padding:40px 32px; }
    h2       { color:#0B2341; font-size:22px; font-weight:700; margin:0 0 12px; }
    p        { color:#5a6a7a; font-size:15px; line-height:1.6; margin:0 0 24px; }
    .btn     { display:inline-block; background:#2ECC71; color:#ffffff !important;
               text-decoration:none; padding:16px 40px; border-radius:12px;
               font-size:16px; font-weight:700; letter-spacing:0.3px;
               box-shadow:0 4px 14px rgba(46,204,113,0.35); }
    .btn:hover { background:#27ae60; }
    .note    { color:#94a3b8; font-size:13px; margin-top:32px; }
    .divider { border:none; border-top:1px solid #e8ecf0; margin:32px 0; }
    .footer  { background:#f8fafc; padding:24px 32px; text-align:center;
               color:#94a3b8; font-size:12px; }
    .badge   { display:inline-block; background:#eafaf2; color:#2ECC71;
               padding:4px 12px; border-radius:20px; font-size:12px;
               font-weight:600; margin-bottom:16px; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="header">
      <div class="logo">Nexa<span>Ma</span></div>
    </div>
    <div class="body">
      <div class="badge">✅ Vérification du compte</div>
      <h2>Bienvenue, ${nom} !</h2>
      <p>
        Merci de vous être inscrit sur <strong>NexaMa</strong>, la plateforme intelligente
        dédiée aux entrepreneurs marocains. Il ne vous reste qu'une seule étape pour
        activer votre compte.
      </p>
      <p style="text-align:center;">
        <a class="btn" href="${verifyUrl}">
          ✓ &nbsp; Confirmer mon adresse e-mail
        </a>
      </p>
      <hr class="divider"/>
      <p class="note">
        Ce lien est valable <strong>24 heures</strong>. Si vous n'avez pas créé de compte
        sur NexaMa, vous pouvez ignorer cet e-mail en toute sécurité.<br/><br/>
        Si le bouton ne fonctionne pas, copiez-collez ce lien dans votre navigateur :<br/>
        <a href="${verifyUrl}" style="color:#2ECC71;word-break:break-all;">${verifyUrl}</a>
      </p>
    </div>
    <div class="footer">
      © ${new Date().getFullYear()} NexaMa — Plateforme entrepreneuriale marocaine<br/>
      Cet e-mail a été envoyé automatiquement, merci de ne pas y répondre.
    </div>
  </div>
</body>
</html>
`;
}

// ─── sendVerificationEmail ──────────────────────────────────────────────────────
async function sendVerificationEmail(email, nom, token) {
  const appUrl    = process.env.APP_URL || 'http://localhost:3000';
  const verifyUrl = `${appUrl}/api/auth/verify-email?token=${token}`;

  await transporter.sendMail({
    from:    process.env.SMTP_FROM || '"NexaMa" <no-reply@nexama.ma>',
    to:      email,
    subject: '✅ Confirmez votre compte NexaMa',
    html:    buildVerificationHtml(nom, verifyUrl),
  });
}

module.exports = { sendVerificationEmail };
