'use strict';

const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { sendVerificationEmail } = require('../utils/mailer');

const router = express.Router();
const prisma = new PrismaClient();

const JWT_SECRET = process.env.JWT_SECRET || 'fallback_secret';

// ─── Helper : générer un token de vérification (JWT 24h) ───────────────────────
function generateVerifToken(userId, email) {
  return jwt.sign({ id: userId, email, purpose: 'email_verification' }, JWT_SECRET, {
    expiresIn: '24h',
  });
}

// ==========================================
// 1. Inscription (Register)
// ==========================================
router.post('/register', async (req, res) => {
  try {
    const { nom_complet, email, mot_de_passe, telephone, role } = req.body;

    // Validation basique
    if (!nom_complet || !email || !mot_de_passe || !role) {
      return res.status(400).json({
        error: 'Champs manquants. Veuillez fournir nom_complet, email, mot_de_passe et role.',
      });
    }

    // Vérifier si l'email est déjà utilisé
    const userExists = await prisma.utilisateurs.findUnique({ where: { email } });
    if (userExists) {
      // Si l'utilisateur existe mais n'a pas vérifié, on renvoie un email
      if (!userExists.is_verified) {
        const token = generateVerifToken(userExists.id, userExists.email);
        try {
          await sendVerificationEmail(userExists.email, userExists.nom_complet, token);
        } catch (mailErr) {
          console.error('Erreur envoi email (renvoi):', mailErr.message);
        }
        return res.status(200).json({
          message: 'Un email de vérification a été renvoyé. Consultez votre boîte de réception.',
          resent: true,
        });
      }
      return res.status(400).json({ error: 'Cet email est déjà utilisé par un compte actif.' });
    }

    // Hachage du mot de passe
    const salt           = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(mot_de_passe, salt);
    const dbRole         = role.toLowerCase();

    // Création de l'utilisateur (is_verified=false, statut=en_attente par défaut)
    const newUser = await prisma.utilisateurs.create({
      data: {
        nom_complet,
        email,
        mot_de_passe: hashedPassword,
        telephone:    telephone || null,
        role:         dbRole,
      },
    });

    // Envoi de l'email de vérification
    const token = generateVerifToken(newUser.id, newUser.email);
    try {
      await sendVerificationEmail(newUser.email, newUser.nom_complet, token);
    } catch (mailErr) {
      // L'utilisateur est créé, mais l'email n'a pas pu être envoyé
      console.error('Erreur envoi email de vérification:', mailErr.message);
      // On ne bloque pas l'inscription, on signale juste le problème
      return res.status(201).json({
        message:     'Compte créé, mais l\'email de vérification n\'a pas pu être envoyé. Contactez le support.',
        emailSent:   false,
        user: { id: newUser.id, nom_complet: newUser.nom_complet, email: newUser.email, role: newUser.role },
      });
    }

    res.status(201).json({
      message:   'Compte créé avec succès ! Un email de confirmation a été envoyé.',
      emailSent: true,
      user: { id: newUser.id, nom_complet: newUser.nom_complet, email: newUser.email, role: newUser.role },
    });
  } catch (error) {
    console.error("Erreur lors de l'inscription:", error);
    res.status(500).json({ error: 'Erreur interne du serveur lors de la création du compte.' });
  }
});

// ==========================================
// 2. Vérification de l'email
// ==========================================
router.get('/verify-email', async (req, res) => {
  const { token } = req.query;

  if (!token) {
    return res.status(400).send(htmlPage('❌ Lien invalide', 'Le lien de vérification est manquant.', false));
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);

    if (payload.purpose !== 'email_verification') {
      return res.status(400).send(htmlPage('❌ Lien invalide', 'Ce lien n\'est pas un lien de vérification valide.', false));
    }

    const user = await prisma.utilisateurs.findUnique({ where: { id: payload.id } });

    if (!user) {
      return res.status(404).send(htmlPage('❌ Compte introuvable', 'Aucun compte n\'est associé à ce lien.', false));
    }

    if (user.is_verified) {
      return res.send(htmlPage('✅ Déjà vérifié', 'Votre compte est déjà actif. Vous pouvez vous connecter.', true));
    }

    // Activer le compte
    await prisma.utilisateurs.update({
      where: { id: user.id },
      data:  { is_verified: true, statut: 'actif' },
    });

    res.send(htmlPage(
      '✅ Email confirmé !',
      `Bienvenue ${user.nom_complet} ! Votre compte NexaMa est maintenant actif. Vous pouvez vous connecter.`,
      true,
    ));
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(400).send(htmlPage(
        '⏰ Lien expiré',
        'Ce lien de vérification a expiré (valable 24h). Veuillez vous réinscrire pour recevoir un nouveau lien.',
        false,
      ));
    }
    console.error('Erreur vérification email:', err);
    res.status(400).send(htmlPage('❌ Lien invalide', 'Ce lien de vérification est invalide ou corrompu.', false));
  }
});

// ==========================================
// 3. Renvoi de l'email de vérification
// ==========================================
router.post('/resend-verification', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email requis.' });

  try {
    const user = await prisma.utilisateurs.findUnique({ where: { email } });
    if (!user) return res.status(404).json({ error: 'Aucun compte trouvé avec cet email.' });
    if (user.is_verified) return res.status(400).json({ error: 'Ce compte est déjà vérifié.' });

    const token = generateVerifToken(user.id, user.email);
    await sendVerificationEmail(user.email, user.nom_complet, token);

    res.json({ message: 'Email de vérification renvoyé avec succès.' });
  } catch (err) {
    console.error('Erreur renvoi vérification:', err);
    res.status(500).json({ error: 'Impossible d\'envoyer l\'email. Réessayez plus tard.' });
  }
});

// ==========================================
// 4. Vérifier le statut (pour le bouton Suivant)
// ==========================================
router.get('/status', async (req, res) => {
  const { email } = req.query;
  if (!email) return res.status(400).json({ error: 'Email requis.' });

  try {
    const user = await prisma.utilisateurs.findUnique({ where: { email } });
    if (!user) return res.status(404).json({ error: 'Utilisateur non trouvé.' });

    res.json({ is_verified: user.is_verified });
  } catch (err) {
    res.status(500).json({ error: 'Erreur serveur.' });
  }
});

// ==========================================
// 5. Connexion (Login)
// ==========================================
router.post('/login', async (req, res) => {
  try {
    const { email, mot_de_passe } = req.body;

    if (!email || !mot_de_passe) {
      return res.status(400).json({ error: 'Veuillez fournir un email et un mot de passe.' });
    }

    let user = await prisma.utilisateurs.findUnique({ where: { email } });
    
    // Auto-seed test accounts if missing
    const testAccounts = ['entrepreneur@gmail.com', 'investisseur@gmail.com', 'prestataire@gmail.com', 'formateur@gmail.com'];
    if (!user && testAccounts.includes(email) && mot_de_passe === 'Nexama2024!') {
      console.log(`Auto-seeding test account: ${email}`);
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(mot_de_passe, salt);
      const role = email.split('@')[0];
      
      user = await prisma.utilisateurs.create({
        data: {
          nom_complet: `Test ${role.charAt(0).toUpperCase() + role.slice(1)}`,
          email,
          mot_de_passe: hashedPassword,
          role,
          statut: 'actif',
          is_verified: true,
          ville: 'Casablanca'
        }
      });

      // Add one piece of mock data per role
      try {
        if (role === 'entrepreneur') {
          await prisma.projets.create({ data: { entrepreneur_id: user.id, nom: 'EcoEnergy Maroc', description: 'Production de panneaux solaires intelligents.', secteur: 'Énergie', budget_recherche: 500000, stade_evolution: 'Prototype' }});
        } else if (role === 'prestataire') {
          await prisma.services_b2b.create({ data: { prestataire_id: user.id, titre: 'Développement Flutter', categorie: 'IT', prix_base: 5000, description: 'Apps mobiles.' }});
        } else if (role === 'formateur') {
          await prisma.cours.create({ data: { formateur_id: user.id, titre: 'Expert Flutter', description: 'Formation avancée.', prix: 199, format_media: 'Vidéo', duree_minutes: 120 }});
        }
      } catch (seedErr) {
        console.warn("Auto-seeding mock data failed (tables might be missing):", seedErr.message);
      }
    }

    if (!user) {
      return res.status(400).json({ error: 'Identifiants invalides (email introuvable).' });
    }

    // Bloquer si email non vérifié
    if (!user.is_verified) {
      return res.status(403).json({
        error:        'Votre compte n\'est pas encore activé. Veuillez confirmer votre adresse e-mail.',
        emailNotVerified: true,
      });
    }

    const isMatch = await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!isMatch) {
      return res.status(400).json({ error: 'Identifiants invalides (mot de passe incorrect).' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' },
    );

    res.json({
      message: 'Connexion réussie',
      token,
      user: { id: user.id, nom_complet: user.nom_complet, email: user.email, role: user.role },
    });
  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({ error: 'Erreur interne du serveur.' });
  }
});

// ─── Page HTML de confirmation (rendue directement dans le navigateur) ──────────
function htmlPage(title, message, success) {
  const color  = success ? '#2ECC71' : '#e74c3c';
  const icon   = success ? '✅' : '❌';
  const appUrl = process.env.APP_URL || 'http://localhost:3000';
  return `<!DOCTYPE html><html lang="fr"><head><meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>${title} — NexaMa</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{min-height:100vh;display:flex;align-items:center;justify-content:center;
       background:linear-gradient(135deg,#0B2341 0%,#1a3a5c 100%);font-family:'Segoe UI',Arial,sans-serif;}
  .card{background:#fff;border-radius:20px;padding:48px 40px;max-width:480px;width:90%;
        text-align:center;box-shadow:0 20px 60px rgba(0,0,0,0.25);}
  .icon{font-size:56px;margin-bottom:20px;}
  h1{color:#0B2341;font-size:24px;font-weight:800;margin-bottom:12px;}
  p{color:#5a6a7a;font-size:15px;line-height:1.6;margin-bottom:32px;}
  .logo{font-size:26px;font-weight:800;color:#0B2341;margin-bottom:32px;}
  .logo span{color:#2ECC71;}
  a.btn{display:inline-block;background:${color};color:#fff;text-decoration:none;
        padding:14px 36px;border-radius:12px;font-size:15px;font-weight:700;}
</style></head><body>
<div class="card">
  <div class="logo">Nexa<span>Ma</span></div>
  <div class="icon">${icon}</div>
  <h1>${title}</h1>
  <p>${message}</p>
</div></body></html>`;
}

module.exports = router;
