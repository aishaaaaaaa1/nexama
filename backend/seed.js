const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('Nexama2024!', 10);

  // 1. Entrepreneur
  const entrepreneur = await prisma.utilisateurs.upsert({
    where: { email: 'entrepreneur@gmail.com' },
    update: { mot_de_passe: password, statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Ahmed Alami',
      email: 'entrepreneur@gmail.com',
      mot_de_passe: password,
      role: 'entrepreneur',
      statut: 'actif',
      is_verified: true,
      ville: 'Casablanca'
    }
  });
  console.log('User Entrepreneur created/updated');

  // 2. Investisseur
  const investisseur = await prisma.utilisateurs.upsert({
    where: { email: 'investisseur@gmail.com' },
    update: { mot_de_passe: password, statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Yassine Mansouri',
      email: 'investisseur@gmail.com',
      mot_de_passe: password,
      role: 'investisseur',
      statut: 'actif',
      is_verified: true,
      ville: 'Rabat'
    }
  });
  console.log('User Investisseur created/updated');

  // 3. Prestataire
  const prestataire = await prisma.utilisateurs.upsert({
    where: { email: 'prestataire@gmail.com' },
    update: { mot_de_passe: password, statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Sofia Bennani',
      email: 'prestataire@gmail.com',
      mot_de_passe: password,
      role: 'prestataire',
      statut: 'actif',
      is_verified: true,
      ville: 'Tangier'
    }
  });
  console.log('User Prestataire created/updated');

  // 4. Formateur
  const formateur = await prisma.utilisateurs.upsert({
    where: { email: 'formateur@gmail.com' },
    update: { mot_de_passe: password, statut: 'actif', is_verified: true },
    create: {
      nom_complet: 'Dr. Karim Tazi',
      email: 'formateur@gmail.com',
      mot_de_passe: password,
      role: 'formateur',
      statut: 'actif',
      is_verified: true,
      ville: 'Marrakesh'
    }
  });
  console.log('User Formateur created/updated');

  // --- MOCK DATA ---

  // Entrepreneur Project
  const project = await prisma.projets.create({
    data: {
      entrepreneur_id: entrepreneur.id,
      nom: 'EcoEnergy Maroc',
      description: 'Production de panneaux solaires intelligents pour le marché local.',
      secteur: 'Énergie Renouvelable',
      ville: 'Casablanca',
      budget_recherche: 500000,
      stade_evolution: 'Prototype',
      trust_score: 8.5
    }
  });

  // Investisseur investment
  await prisma.investissements.create({
    data: {
      projet_id: project.id,
      investisseur_id: investisseur.id,
      montant: 100000,
      statut: 'valide'
    }
  });

  // Prestataire Service
  await prisma.services_b2b.create({
    data: {
      prestataire_id: prestataire.id,
      titre: 'Développement d\'Applications Mobile Flutter',
      categorie: 'Développement',
      prix_base: 5000,
      description: 'Création d\'applications performantes pour iOS et Android.'
    }
  });

  // Formateur Course
  await prisma.cours.create({
    data: {
      formateur_id: formateur.id,
      titre: 'Devenir Freelance au Maroc',
      description: 'Guide complet pour lancer son activité de prestataire.',
      prix: 199,
      format_media: 'Vidéo',
      duree_minutes: 180
    }
  });

  console.log('Mock data seeded successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
