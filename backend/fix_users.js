const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const pass = await bcrypt.hash('Nexama2024!', 10);
  const users = [
    {e:'entrepreneur@gmail.com', r:'entrepreneur'},
    {e:'investisseur@gmail.com', r:'investisseur'},
    {e:'prestataire@gmail.com', r:'prestataire'},
    {e:'formateur@gmail.com', r:'formateur'}
  ];

  for (const u of users) {
    await prisma.utilisateurs.upsert({
      where: { email: u.e },
      update: { mot_de_passe: pass, is_verified: true, statut: 'actif' },
      create: { 
        email: u.e, 
        nom_complet: u.e.split('@')[0], 
        mot_de_passe: pass, 
        role: u.r, 
        is_verified: true, 
        statut: 'actif' 
      }
    });
  }
  console.log('✅ Succès ! Vos 4 comptes sont prêts avec le mot de passe : Nexama2024!');
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect();
  });
