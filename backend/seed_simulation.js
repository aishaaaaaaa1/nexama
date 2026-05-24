const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function seed() {
  console.log('--- DÉBUT DE LA SIMULATION RÉELLE ---');

  const password = await bcrypt.hash('Nexama2024!', 10);

  // 1. CRÉATION DES UTILISATEURS DE TEST
  const users = {
    entrepreneur: await prisma.utilisateurs.upsert({
      where: { email: 'entrepreneur@gmail.com' },
      update: { mot_de_passe: password, statut: 'actif', is_verified: true },
      create: { nom_complet: 'Anas El Mansouri', email: 'entrepreneur@gmail.com', mot_de_passe: password, role: 'entrepreneur', statut: 'actif', is_verified: true, ville: 'Casablanca' }
    }),
    investisseur: await prisma.utilisateurs.upsert({
      where: { email: 'investisseur@gmail.com' },
      update: { mot_de_passe: password, statut: 'actif', is_verified: true },
      create: { nom_complet: 'Karim Bennani', email: 'investisseur@gmail.com', mot_de_passe: password, role: 'investisseur', statut: 'actif', is_verified: true, ville: 'Rabat' }
    }),
    prestataire: await prisma.utilisateurs.upsert({
      where: { email: 'prestataire@gmail.com' },
      update: { mot_de_passe: password, statut: 'actif', is_verified: true },
      create: { nom_complet: 'Yassine Digital', email: 'prestataire@gmail.com', mot_de_passe: password, role: 'prestataire', statut: 'actif', is_verified: true, ville: 'Tanger' }
    }),
    formateur: await prisma.utilisateurs.upsert({
      where: { email: 'formateur@gmail.com' },
      update: { mot_de_passe: password, statut: 'actif', is_verified: true },
      create: { nom_complet: 'Pr. Salma Radi', email: 'formateur@gmail.com', mot_de_passe: password, role: 'formateur', statut: 'actif', is_verified: true, ville: 'Marrakech' }
    }),
    admin: await prisma.utilisateurs.upsert({
      where: { email: 'admin@nexama.ma' },
      update: { mot_de_passe: password, statut: 'actif', is_verified: true },
      create: { nom_complet: 'Super Admin NexaMa', email: 'admin@nexama.ma', mot_de_passe: password, role: 'administrateur', statut: 'actif', is_verified: true }
    })
  };

  console.log('✅ Utilisateurs créés.');

  // 2. PROJET POUR L'ENTREPRENEUR
  const projet = await prisma.projets.create({
    data: {
      entrepreneur_id: users.entrepreneur.id,
      nom: 'GreenAgri Tech',
      description: 'Système d\'irrigation intelligent basé sur l\'IA pour optimiser la consommation d\'eau dans les fermes du Souss.',
      secteur: 'AgriTech',
      budget_recherche: 850000,
      stade_evolution: 'MVP',
      ville: 'Agadir'
    }
  });

  console.log('✅ Projet "GreenAgri Tech" créé.');

  // 3. INVESTISSEMENT RÉEL (Lien entre Investisseur et Entrepreneur)
  await prisma.investissements.create({
    data: {
      investisseur_id: users.investisseur.id,
      projet_id: projet.id,
      montant: 250000,
      statut: 'Validé'
    }
  });

  console.log('✅ Karim Bennani a investi 250 000 MAD dans GreenAgri Tech.');

  // 4. SERVICE ET COMMANDE (Lien entre Prestataire et Entrepreneur)
  const service = await prisma.services_b2b.create({
    data: {
      prestataire_id: users.prestataire.id,
      titre: 'Développement Dashboard Analytique',
      categorie: 'IT & Digital',
      description: 'Création d\'un dashboard sur mesure pour le suivi des données agricoles.',
      prix_basique: 15000,
      prix_standard: 22000,
      delai_livraison: 14,
      tags: ['dashboard', 'analytics'],
    },
  });

  await prisma.commandes_b2b.create({
    data: {
      service_id: service.id,
      client_id: users.entrepreneur.id,
      prestataire_id: users.prestataire.id,
      montant_total: 15000,
      statut: 'EN_COURS',
    },
  });

  console.log('✅ Anas a commandé un dashboard chez Yassine Digital.');

  // 5. COURS ET FORUM (Simulation d'activité)
  await prisma.cours.create({
    data: {
      formateur_id: users.formateur.id,
      titre: 'Marketing Digital pour Startups Marocaines',
      description: 'Comment acquérir ses 1000 premiers clients au Maroc.',
      categorie: 'Marketing',
      niveau: 'debutant',
      prix: 490,
      duree_totale: 180,
    },
  });

  const post = await prisma.forum_posts.create({
    data: {
      utilisateur_id: users.entrepreneur.id,
      titre: 'Conseils pour l\'export vers l\'Afrique ?',
      contenu: 'Bonjour, je cherche des retours d\'expérience sur l\'exportation de solutions technologiques vers le Sénégal.',
      categorie: 'Export'
    }
  });

  await prisma.forum_replies.create({
    data: {
      post_id: post.id,
      utilisateur_id: users.investisseur.id,
      contenu: 'Très bon sujet ! J\'ai des contacts à la CFC qui pourraient t\'aider.'
    }
  });

  console.log('✅ Activité forum et cours générée.');

  // 6. MESSAGES (Interaction directe)
  await prisma.messages.create({
    data: {
      expediteur_id: users.investisseur.id,
      destinataire_id: users.entrepreneur.id,
      contenu: 'Félicitations pour votre levée de fonds ! On se voit demain pour la signature ?'
    }
  });

  console.log('✅ Simulation de messagerie complétée.');

  console.log('--- SIMULATION TERMINÉE AVEC SUCCÈS ---');
}

seed()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
