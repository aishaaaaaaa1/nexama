const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const NotificationService = require('./notification.service');

class ProjectExecutionService {
  /**
   * Créer un projet collaboratif
   */
  static async createProject(ownerId, data) {
    const { nom, description, date_debut, date_fin, budget_initial } = data;
    
    return prisma.$transaction(async (tx) => {
      const project = await tx.projects_execution.create({
        data: {
          owner_id: ownerId,
          nom,
          description,
          date_debut: new Date(date_debut),
          date_fin: date_fin ? new Date(date_fin) : null,
          budget_initial: parseFloat(budget_initial || 0)
        }
      });

      // Ajouter le créateur comme Owner dans la table members
      await tx.project_members.create({
        data: {
          project_id: project.id,
          utilisateur_id: ownerId,
          role: 'owner'
        }
      });

      return project;
    });
  }

  /**
   * Récupérer les KPIs d'un projet
   */
  static async getProjectStats(projectId) {
    const tasks = await prisma.tasks.findMany({ where: { project_id: projectId } });
    const expenses = await prisma.project_execution_expenses.findMany({ where: { project_id: projectId } });
    const project = await prisma.projects_execution.findUnique({ where: { id: projectId } });

    const totalTasks = tasks.length;
    const completedTasks = tasks.filter(t => t.statut === 'done').length;
    const progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    const totalSpent = expenses.reduce((sum, e) => sum + e.montant, 0);
    const budgetBurnRate = project.budget_initial > 0 ? (totalSpent / project.budget_initial) * 100 : 0;

    return {
      progress: Math.round(progress),
      totalTasks,
      completedTasks,
      totalSpent,
      budgetRemaining: project.budget_initial - totalSpent,
      budgetBurnRate: Math.round(budgetBurnRate)
    };
  }

  /**
   * Gérer les tâches (Kanban)
   */
  static async updateTaskStatus(taskId, newStatus) {
    const task = await prisma.tasks.update({
      where: { id: taskId },
      data: { statut: newStatus },
      include: { assignee: true, project: true }
    });

    if (task.assignee) {
      await NotificationService.notify(
        task.assignee.id,
        "Mise à jour de tâche",
        `Le statut de votre tâche "${task.titre}" a été mis à jour vers : ${newStatus}.`
      );
    }

    return task;
  }
}

module.exports = ProjectExecutionService;
