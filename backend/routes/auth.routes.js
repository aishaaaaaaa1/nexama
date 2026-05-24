'use strict';

const express  = require('express');
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { sendVerificationEmail } = require('../utils/mailer');
const { logAction } = require('../utils/auditLogger');
const { verifyToken } = require('../utils/authMiddleware');

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
    
    // Auto-seed or Update test accounts
    const testAccounts = ['entrepreneur@gmail.com', 'investisseur@gmail.com', 'prestataire@gmail.com', 'formateur@gmail.com', 'admin@nexama.ma'];
    if (testAccounts.includes(email) && mot_de_passe === 'Nexama2024!') {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(mot_de_passe, salt);
      let role = email.split('@')[0];
      if (role === 'admin') role = 'administrateur';
      
      const userData = {
        nom_complet: `Test ${role.charAt(0).toUpperCase() + role.slice(1)}`,
        email,
        mot_de_passe: hashedPassword,
        role,
        statut: 'actif',
        is_verified: true,
        ville: 'Casablanca'
      };

      if (!user) {
        console.log(`Auto-seeding test account: ${email}`);
        user = await prisma.utilisateurs.create({ data: userData });
      } else {
        // Force update to ensure test account is functional
        console.log(`Updating test account to standard test state: ${email}`);
        user = await prisma.utilisateurs.update({ where: { email }, data: userData });
      }

      // --- GÉNÉRATION DE LA SIMULATION INTERCONNECTÉE ---
      try {
        if (role === 'entrepreneur') {
          const projet = await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000001' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000001',
              entrepreneur_id: user.id,
              nom: 'EcoWater Morocco',
              description: 'Système d\'irrigation intelligent pour économiser 40% d\'eau.',
              secteur: 'AgriTech',
              budget_recherche: 450000,
              stade_evolution: 'MVP',
              ville: 'Agadir',
              region: 'Souss-Massa',
              trust_score: 85
            }
          });

          await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000006' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000006',
              entrepreneur_id: user.id,
              nom: 'NexaPay',
              description: 'Solution de paiement pour les commerçants ruraux.',
              secteur: 'Fintech',
              budget_recherche: 850000,
              stade_evolution: 'Croissance',
              ville: 'Casablanca',
              region: 'Casablanca-Settat',
              trust_score: 92
            }
          });
          
          await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000007' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000007',
              entrepreneur_id: user.id,
              nom: 'SolarFarm Ouarzazate',
              description: 'Installation de panneaux solaires bifaciaux.',
              secteur: 'Énergie',
              budget_recherche: 2500000,
              stade_evolution: 'Expansion',
              ville: 'Ouarzazate',
              region: 'Drâa-Tafilalet',
              trust_score: 95
            }
          });

          await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000008' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000008',
              entrepreneur_id: user.id,
              nom: 'HealthConnect',
              description: 'Plateforme de télémédecine pour zones rurales.',
              secteur: 'Santé',
              budget_recherche: 300000,
              stade_evolution: 'Amorçage',
              ville: 'Rabat',
              region: 'Rabat-Salé-Kénitra',
              trust_score: 78
            }
          });

          await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000009' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000009',
              entrepreneur_id: user.id,
              nom: 'LogiTrack Tanger',
              description: 'Gestion optimisée du transport de marchandises.',
              secteur: 'Logistique',
              budget_recherche: 1200000,
              stade_evolution: 'MVP',
              ville: 'Tanger',
              region: 'Tanger-Tétouan-Al Hoceïma',
              trust_score: 88
            }
          });

          await prisma.projets.upsert({
            where: { id: '00000000-0000-0000-0000-000000000010' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000010',
              entrepreneur_id: user.id,
              nom: 'E-Souk Artisanat',
              description: 'Marketplace pour les artisans marocains.',
              secteur: 'E-commerce',
              budget_recherche: 150000,
              stade_evolution: 'Idée',
              ville: 'Marrakech',
              region: 'Marrakech-Safi',
              trust_score: 70
            }
          });

          // Créer un investisseur fictif s'il n'existe pas pour l'investissement
          const inv = await prisma.utilisateurs.findFirst({ where: { role: 'investisseur' } });
          if (inv) {
            await prisma.investissements.upsert({
              where: { id: '00000000-0000-0000-0000-000000000002' },
              update: {},
              create: {
                id: '00000000-0000-0000-0000-000000000002',
                investisseur_id: inv.id,
                projet_id: projet.id,
                montant: 250000,
                statut: 'Validé'
              }
            });
          }
        }
        
        if (role === 'prestataire') {
          await prisma.services_b2b.upsert({
            where: { id: '00000000-0000-0000-0000-000000000003' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000003',
              prestataire_id: user.id,
              titre: 'Développement Dashboard Analytique',
              categorie: 'IT & Digital',
              description: 'Dashboard sur mesure.',
              prix_basique: 15000,
              prix_standard: 22000,
              prix_premium: 30000,
              delai_livraison: 14,
              tags: ['dashboard', 'analytics'],
            },
          });
        }

        if (role === 'formateur') {
          await prisma.cours.upsert({
            where: { id: '00000000-0000-0000-0000-000000000004' },
            update: {},
            create: {
              id: '00000000-0000-0000-0000-000000000004',
              formateur_id: user.id,
              titre: 'Marketing Digital pour Startups',
              description: 'Formation complète.',
              categorie: 'Marketing',
              niveau: 'debutant',
              prix: 490,
              duree_totale: 180,
            },
          });
        }

        if (role === 'investisseur') {
          // Créer un profil de préférences pour le matching
          await prisma.investisseur_profiles.upsert({
            where: { utilisateur_id: user.id },
            update: {},
            create: {
              utilisateur_id: user.id,
              secteurs_interet: ['AgriTech', 'Fintech', 'IT & Digital'],
              ticket_min: 100000,
              ticket_max: 1000000,
              regions_pref: ['Casablanca', 'Rabat', 'Agadir'],
              type_invest: 'Equity',
              credibility_score: 85.0
            }
          });

          const ent = await prisma.utilisateurs.findFirst({ where: { role: 'entrepreneur' } });
          if (ent) {
            const proj = await prisma.projets.findFirst({ where: { entrepreneur_id: ent.id } });
            if (proj) {
              await prisma.investissements.upsert({
                where: { id: '00000000-0000-0000-0000-000000000005' },
                update: {},
                create: {
                  id: '00000000-0000-0000-0000-000000000005',
                  investisseur_id: user.id,
                  projet_id: proj.id,
                  montant: 500000,
                  statut: 'Actif'
                }
              });
            }
          }
        }
      } catch (seedErr) {
        console.warn("Simulation seeding partially skipped:", seedErr.message);
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

    // Log d'audit
    await logAction(user.id, 'CONNEXION_USER', `Connexion réussie (${user.role})`);

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

router.get('/notifications/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await prisma.utilisateurs.findUnique({ where: { id: userId } });
    if (!user) return res.status(404).json({ error: 'Utilisateur non trouvé' });

    // Simulation de notifications selon le rôle
    let notifications = [
      { id: 1, titre: "Bienvenue !", message: `Bonjour ${user.nom_complet}, ravi de vous voir sur NexaMa.`, date: "Maintenant", lu: false, icon: "waving_hand" },
      { id: 2, titre: "Sécurité", message: "Pensez à activer la double authentification pour protéger votre compte.", date: "Il y a 1h", lu: true, icon: "security" }
    ];

    if (user.role === 'entrepreneur') {
      notifications.push({ id: 3, titre: "Nouvel Investissement", message: "Un investisseur a consulté votre projet GreenAgri Tech.", date: "Il y a 2h", lu: false, icon: "trending_up" });
    } else if (user.role === 'investisseur') {
      notifications.push({ id: 3, titre: "Opportunité", message: "Nouveau projet AgriTech disponible dans votre région.", date: "Il y a 30 min", lu: false, icon: "lightbulb" });
    } else if (user.role === 'prestataire') {
      notifications.push({ id: 3, titre: "Nouvelle Mission", message: "Une startup recherche un développeur Flutter.", date: "Il y a 15 min", lu: false, icon: "work_outline" });
    } else if (user.role === 'formateur') {
      notifications.push({ id: 3, titre: "Nouvel Apprenant", message: "Un nouvel élève s'est inscrit à votre cours.", date: "Hier", lu: false, icon: "school" });
    }

    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/debug/fix-profile', verifyToken, async (req, res) => {
  try {
    // 1. S'assurer que des projets existent
    const projetsCount = await prisma.projets.count();
    if (projetsCount === 0) {
      console.log("Seeding projects from debug endpoint...");
      // Trouver ou créer un entrepreneur pour lier les projets
      let entrepreneur = await prisma.utilisateurs.findFirst({ where: { role: 'entrepreneur' } });
      if (!entrepreneur) {
        entrepreneur = await prisma.utilisateurs.create({
          data: {
            email: 'entrepreneur_test@nexama.ma',
            mot_de_passe: 'seeded_password',
            nom_complet: 'Test Entrepreneur',
            role: 'entrepreneur',
            is_verified: true
          }
        });
      }

      const demoProjects = [
        {
          id: '00000000-0000-0000-0000-000000000101',
          entrepreneur_id: entrepreneur.id,
          nom: 'EcoWater Morocco',
          description: 'Système d\'irrigation intelligent pour économiser 40% d\'eau.',
          secteur: 'AgriTech',
          budget_recherche: 450000,
          stade_evolution: 'MVP',
          ville: 'Agadir',
          region: 'Souss-Massa',
          trust_score: 85
        },
        {
          id: '00000000-0000-0000-0000-000000000102',
          entrepreneur_id: entrepreneur.id,
          nom: 'NexaPay',
          description: 'Solution de paiement pour les commerçants ruraux.',
          secteur: 'Fintech',
          budget_recherche: 850000,
          stade_evolution: 'Croissance',
          ville: 'Casablanca',
          region: 'Casablanca-Settat',
          trust_score: 92
        },
        {
          id: '00000000-0000-0000-0000-000000000103',
          entrepreneur_id: entrepreneur.id,
          nom: 'SolarFarm Ouarzazate',
          description: 'Installation de panneaux solaires bifaciaux.',
          secteur: 'Énergie',
          budget_recherche: 2500000,
          stade_evolution: 'Expansion',
          ville: 'Ouarzazate',
          region: 'Drâa-Tafilalet',
          trust_score: 95
        }
      ];

      for (const p of demoProjects) {
        await prisma.projets.upsert({
          where: { id: p.id },
          update: p,
          create: p
        });
      }
    }

    // 3. Seeding Finance (Auto-Entrepreneur)
    if (req.user.role === 'entrepreneur') {
      const invoicesCount = await prisma.factures.count({ where: { utilisateur_id: req.user.id } });
      if (invoicesCount === 0) {
        await prisma.factures.create({
          data: {
            utilisateur_id: req.user.id,
            numero_ref: 'FAC-2024-001',
            client_nom: 'Digital Solutions SARL',
            client_ice: '001234567890001',
            total_ht: 15000,
            tva: 3000,
            total_ttc: 18000,
            statut: 'payee',
            date_echeance: new Date('2024-06-15'),
            items: {
              create: [
                { designation: 'Développement Web Front-end', quantite: 1, prix_unitaire: 15000, total_ht: 15000, total_ttc: 18000 }
              ]
            }
          }
        });

        await prisma.depenses.createMany({
          data: [
            { utilisateur_id: req.user.id, categorie: 'Marketing', montant: 1200, description: 'Publicité Facebook' },
            { utilisateur_id: req.user.id, categorie: 'Logiciels', montant: 450, description: 'Abonnement NexaMa Premium' }
          ]
        });

        await prisma.rappels_fiscaux.createMany({
          data: [
            { utilisateur_id: req.user.id, type_taxe: 'TVA Trimestre 2', date_limite: new Date('2024-07-20'), montant_estime: 3000 },
            { utilisateur_id: req.user.id, type_taxe: 'Cotisation CNSS', date_limite: new Date('2024-05-30'), montant_estime: 850 }
          ]
        });
      }
    }

    if (req.user.role === 'investisseur') {
      const profile = await prisma.investisseur_profiles.upsert({
        where: { utilisateur_id: req.user.id },
        update: {
          secteurs_interet: ['AgriTech', 'Fintech', 'IT & Digital', 'Santé', 'Énergie', 'Logistique', 'E-commerce'],
          ticket_min: 10000,
          ticket_max: 10000000,
          regions_pref: ['Casablanca', 'Rabat', 'Agadir', 'Marrakech', 'Tanger', 'Ouarzazate', 'Souss-Massa'],
          type_invest: 'Equity'
        },
        create: {
          utilisateur_id: req.user.id,
          secteurs_interet: ['AgriTech', 'Fintech', 'IT & Digital', 'Santé', 'Énergie', 'Logistique', 'E-commerce'],
          ticket_min: 10000,
          ticket_max: 10000000,
          regions_pref: ['Casablanca', 'Rabat', 'Agadir', 'Marrakech', 'Tanger', 'Ouarzazate', 'Souss-Massa'],
          type_invest: 'Equity'
        }
      });
      return res.json({ message: "Database seeded and profile fixed", profile });
    }
    res.json({ message: "Database seeded but user is not an investor" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
