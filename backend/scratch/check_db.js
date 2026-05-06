const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function check() {
  try {
    const users = await prisma.utilisateurs.count();
    const projects = await prisma.projets.count();
    const profiles = await prisma.investisseur_profiles.count();
    
    console.log('--- DATABASE DIAGNOSTIC ---');
    console.log('Total Users:', users);
    console.log('Total Projects:', projects);
    console.log('Investor Profiles:', profiles);
    
    if (projects > 0) {
      const firstProject = await prisma.projets.findFirst();
      console.log('Example Project:', firstProject.nom, 'Sector:', firstProject.secteur);
    }
    
    const allUsers = await prisma.utilisateurs.findMany({ select: { email: true, role: true } });
    console.log('Users list:', allUsers);

  } catch (e) {
    console.error('Error checking DB:', e);
  } finally {
    await prisma.$disconnect();
  }
}

check();
