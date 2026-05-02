const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('Nexama2024!', 10);

  console.log('--- Nettoyage de la base de données ---');
  // Suppression optionnelle pour éviter les doublons lors des tests
  // await prisma.projets.deleteMany({});
  // await prisma.utilisateurs.deleteMany({});

  console.log('--- Création des comptes ---');

  // 1. Entrepreneur
  const entrepreneur = await prisma.utilisateurs.upsert({
    where: { email: 'entrepreneur@gmail.com' },
    update: { statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Anass Entrepreneur',
      email: 'entrepreneur@gmail.com',
      mot_de_passe: passwordHash,
      role: 'entrepreneur',
      statut: 'actif',
      is_verified: true,
      ville: 'Casablanca',
    },
  });

  // ... (projet créé ici) ...
  await prisma.projets.create({
    data: {
      entrepreneur_id: entrepreneur.id,
      nom: 'Smart Agri Morocco',
      description: 'Système d\'irrigation intelligent utilisant l\'IA.',
      secteur: 'AgriTech',
      budget_recherche: 500000,
      stade_evolution: 'Amorçage'
    }
  }).catch(e => {});

  // 2. Investisseur
  await prisma.utilisateurs.upsert({
    where: { email: 'investisseur@gmail.com' },
    update: { statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Karim Investisseur',
      email: 'investisseur@gmail.com',
      mot_de_passe: passwordHash,
      role: 'investisseur',
      statut: 'actif',
      is_verified: true,
      ville: 'Marrakech',
    },
  });

  // 3. Prestataire
  await prisma.utilisateurs.upsert({
    where: { email: 'prestataire@gmail.com' },
    update: { statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Sami Prestataire',
      email: 'prestataire@gmail.com',
      mot_de_passe: passwordHash,
      role: 'prestataire',
      statut: 'actif',
      is_verified: true,
      ville: 'Tanger',
    },
  });

  // 4. Formateur
  await prisma.utilisateurs.upsert({
    where: { email: 'formateur@gmail.com' },
    update: { statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Leila Formateur',
      email: 'formateur@gmail.com',
      mot_de_passe: passwordHash,
      role: 'formateur',
      statut: 'actif',
      is_verified: true,
      ville: 'Rabat',
    },
  });

  console.log('✅ Base de données peuplée avec succès !');
}

main()
  .catch((e) => {
    console.error('❌ Erreur lors du seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

