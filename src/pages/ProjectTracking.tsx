import { motion, AnimatePresence } from 'framer-motion';
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Toaster } from '@/components/ui/toaster';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Calendar } from 'lucide-react';
import { CheckCircle, XCircle, Clock, Users, Upload, FileText, MessageCircle, Bell, PieChart, TrendingUp } from 'lucide-react';
import { useState } from 'react';

// Dummy data
const stats = [
  { label: 'Projets totaux', value: 24, icon: <FileText className="h-5 w-5 text-purple-500" /> },
  { label: 'Projets actifs', value: 12, icon: <TrendingUp className="h-5 w-5 text-green-500" /> },
  { label: 'Projets terminés', value: 10, icon: <CheckCircle className="h-5 w-5 text-green-500" /> },
  { label: 'Tâches en retard', value: 3, icon: <XCircle className="h-5 w-5 text-red-500" /> },
  { label: 'Taux de progression', value: '78%', icon: <PieChart className="h-5 w-5 text-purple-500" /> },
  { label: 'Membres actifs', value: 45, icon: <Users className="h-5 w-5 text-blue-500" /> },
  { label: 'Temps moyen/projet', value: '12h', icon: <Clock className="h-5 w-5 text-gray-500" /> },
  { label: 'Productivité équipe', value: '+12%', icon: <TrendingUp className="h-5 w-5 text-green-500" /> },
];

const projects = [
  {
    id: 1,
    name: 'Refonte du site NexaMa',
    description: 'Modernisation de l\'interface utilisateur avec React et Tailwind',
    status: 'En cours',
    progress: 65,
    deadline: '2026-06-30',
    priority: 'Haute',
    members: ['Alice', 'Bob', 'Charlie'],
    tasksCount: 24,
    timeLeft: '15 jours',
    tags: ['Design', 'Frontend'],
    lastActivity: '2h ago',
  },
  {
    id: 2,
    name: 'Intégration API paiement',
    description: 'Mise en place du paiement Stripe pour les abonnements',
    status: 'En attente',
    progress: 30,
    deadline: '2026-05-20',
    priority: 'Urgente',
    members: ['David', 'Eve'],
    tasksCount: 12,
    timeLeft: '4 jours',
    tags: ['Backend', 'Payments'],
    lastActivity: '1 jour ago',
  },
  {
    id: 3,
    name: 'Campagne marketing Q2',
    description: 'Lancement de la nouvelle fonctionnalité IA',
    status: 'Terminé',
    progress: 100,
    deadline: '2026-04-30',
    priority: 'Moyenne',
    members: ['Frank', 'Grace'],
    tasksCount: 18,
    timeLeft: '0 jours',
    tags: ['Marketing', 'Campaign'],
    lastActivity: '3 jours ago',
  },
];

const kanbanColumns = [
  { id: 'todo', title: 'À faire', tasks: [] },
  { id: 'inprogress', title: 'En cours', tasks: [] },
  { id: 'review', title: 'En révision', tasks: [] },
  { id: 'done', title: 'Terminé', tasks: [] },
];

// Simulate some tasks for kanban
const kanbanTasks = [
  { id: 1, title: 'Créer maquettes homepage', assignee: 'Alice', deadline: '2026-05-18', priority: 'Haute', comments: 2, attachments: 1 },
  { id: 2, title: 'Implémenter auth JWT', assignee: 'Bob', deadline: '2026-05-22', priority: 'Urgente', comments: 5, attachments: 3 },
  { id: 3, title: 'Rédaction blog lancement', assignee: 'Charlie', deadline: '2026-06-01', priority: 'Moyenne', comments: 0, attachments: 0 },
  { id: 4, title: 'Review code payment', assignee: 'David', deadline: '2026-05-20', priority: 'Haute', comments: 1, attachments: 2 },
];
kanbanColumns[0].tasks = kanbanTasks.slice(0, 2);
kanbanColumns[1].tasks = kanbanTasks.slice(2, 3);
kanbanColumns[2].tasks = kanbanTasks.slice(3, 4);

// Analytics data
const analyticsData = [
  { name: 'Jan', projets: 4, taches: 20 },
  { name: 'Fev', projets: 6, taches: 35 },
  { name: 'Mar', projets: 8, taches: 50 },
  { name: 'Avr', projets: 10, taches: 65 },
  { name: 'Mai', projets: 12, taches: 80 },
  { name: 'Jun', projets: 14, taches: 95 },
];

export default function ProjectTracking() {
  const [view, setView] = useState<'liste' | 'kanban' | 'timeline' | 'calendrier'>('liste');
  const [selectedProject, setSelectedProject] = useState<null | typeof projects[0>>(null);

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <Toaster />
      {/* Header */}
      <motion.div
        initial={{ y: -20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6 }}
        className="mb-8"
      >
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Suivi de Projet</h1>
            <p className="mt-1 text-sm text-gray-500">
              Espace complet de gestion et suivi des projets en temps réel
            </p>
          </div>
          <div className="mt-4 sm:mt-0 sm:flex sm:space-x-3">
            <Button variant="outline" className="flex items-center space-x-2">
              + Nouveau Projet
            </Button>
            <Button variant="secondary">Exporter</Button>
            <Select defaultValue="Liste" onValueChange={v => setView(v as any)} className="w-48">
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Sélecteur de vue" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="liste">Liste</SelectItem>
                <SelectItem value="kanban">Kanban</SelectItem>
                <SelectItem value="timeline">Timeline</SelectItem>
                <SelectItem value="calendrier">Calendrier</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </motion.div>

      {/* Stats Cards */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.6 }}
        className="grid gap-4 mb-8"
      >
        {stats.map((stat, i) => (
          <motion.key
            key={i}
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: i * 0.05, duration: 0.4 }}
          >
            <Card className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader className="flex flex-col items-start gap-2">
                <div className="flex items-center">
                  {stat.icon}
                  <span className="ml-2 text-sm font-medium text-gray-600">{stat.label}</span>
                </div>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </CardHeader>
            </Card>
          </motion.key>
        ))}
      </motion.div>

      {/* Tabs for different sections */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.6 }}
        className="space-y-8"
      >
        <Tabs defaultValue="liste" className="w-full">
          <TabsList className="grid w-full grid-cols-2 gap-4 mb-6">
            <TabsTrigger value="liste">Liste des projets</TabsTrigger>
            <TabsTrigger value="kanban">Kanban Board</TabsTrigger>
            <TabsTrigger value="timeline">Timeline / Gantt</TabsTrigger>
            <TabsTrigger value="taches">Tâches</TabsTrigger>
            <TabsTrigger value="equipe">Équipe & Collaboration</TabsTrigger>
            <TabsTrigger value="analytics">Analytics & Performance</TabsTrigger>
            <TabsTrigger value="calendrier">Calendrier</TabsTrigger>
            <TabsTrigger value="notifications">Notifications</TabsTrigger>
            <TabsTrigger value="fichiers">Fichiers & Documents</TabsTrigger>
            <TabsTrigger value="clients">Clients</TabsTrigger>
          </TabsList>

          {/* Liste des projets */}
          <TabsContent value="liste" className="space-y-4">
            {projects.map(proj => (
              <motion.key
                key={proj.id}
                initial={{ y: 10, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: projects.indexOf(proj) * 0.03, duration: 0.4 }}
              >
                <Card className="bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow cursor-pointer"
                      onClick={() => setSelectedProject(proj)}>
                  <CardHeader className="pb-4">
                    <div className="flex justify-between items-start">
                      <div>
                        <h2 className={proj.status === 'Terminé' ? 'text-lg font-medium text-green-600' : proj.status === 'En cours' ? 'text-lg font-medium text-blue-600' : proj.status === 'En attente' ? 'text-lg font-medium text-yellow-600' : 'text-lg font-medium text-red-600'}>
                          {proj.name}
                        </h2>
                        <p className="mt-1 text-sm text-gray-600 line-clamp-2">{proj.description}</p>
                      </div>
                      <div className="text-right">
                        <span className={`px-2 py-0.5 text-xs rounded-full ${
                          proj.status === 'Terminé' ? 'bg-green-100 text-green-800' :
                          proj.status === 'En cours' ? 'bg-blue-100 text-blue-800' :
                          proj.status === 'En attente' ? 'bg-yellow-100 text-yellow-800' :
                          'bg-red-100 text-red-800'
                        }`}>
                          {proj.status}
                        </span>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-2">
                          <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                          <span className="text-xs text-gray-500">Barre de progression</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2.5 mt-1">
                          <div className={`bg-purple-600 h-2.5 rounded-full transition-all duration-300` style={{ width: `${proj.progress}%` }}></div>
                        </div>
                      </div>
                      <div className="text-right text-sm space-y-1">
                        <div className="flex items-center">
                          <Calendar className="h-4 w-4 text-gray-400 mr-1" />
                          <span>{proj.deadline}</span>
                        </div>
                        <div className="flex items-center">
                          <span className={`px-1.5 py-0.5 text-xs rounded ${
                            proj.priority === 'Faible' ? 'bg-green-100 text-green-800' :
                            proj.priority === 'Moyenne' ? 'bg-yellow-100 text-yellow-800' :
                            proj.priority === 'Haute' ? 'bg-orange-100 text-orange-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {proj.priority}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="flex flex-wrap gap-3 text-xs text-gray-500">
                      {proj.members.map(m => (
                        <span key={m} className="flex items-center space-x-1">
                          <Users className="h-3 w-3" />
                          {m}
                        </span>
                      ))}
                      <span>
                        <FileText className="h-3 w-3 mr-1" /> {proj.tasksCount} tâches
                      </span>
                      <span>
                        <Clock className="h-3 w-3 mr-1" /> {proj.timeLeft}
                      </span>
                      <div className="flex gap-2">
                        {proj.tags.map(tag => (
                          <span key={tag} className="px-2 py-0.5 text-xs bg-gray-100 rounded-full">{tag}</span>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                  <CardFooter className="pt-4 border-t border-gray-100">
                    <div className="flex justify-between text-sm text-gray-500">
                      <span>Dernière activité : {proj.lastActivity}</span>
                      <Button variant="ghost" size="sm">Voir détails</Button>
                    </div>
                  </CardFooter>
                </Card>
              </motion.key>
            ))}
          </TabsContent>

          {/* Kanban Board */}
          <TabsContent value="kanban" className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              {kanbanColumns.map(col => (
                <motion.div
                  key={col.id}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: kanbanColumns.indexOf(col) * 0.05, duration: 0.5 }}
                  className="bg-white rounded-xl border border-gray-100 shadow-sm p-4 min-h-[300px]"
                >
                  <div className="flex justify-between items-start mb-3">
                    <h3 className="font-semibold text-gray-800">{col.title}</h3>
                    <span className="text-xs text-gray-500">{col.tasks.length}</span>
                  </div>
                  <div className="space-y-3 min-h-[200px]">
                    {col.tasks.map(task => (
                      <motion.div
                        key={task.id}
                        initial={{ y: 10, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: task.id * 0.02, duration: 0.3 }}
                        className="bg-gray-50 rounded-lg p-3 border border-gray-200 shadow-sm"
                      >
                        <div className="flex justify-between items-start">
                          <h4 className="font-medium text-gray-900">{task.title}</h4>
                          <span className={`px-1.5 py-0.5 text-xs rounded ${
                            task.priority === 'Faible' ? 'bg-green-100 text-green-800' :
                            task.priority === 'Moyenne' ? 'bg-yellow-100 text-yellow-800' :
                            task.priority === 'Haute' ? 'bg-orange-100 text-orange-800' :
                            'bg-red-100 text-red-800'
                          }`}>
                            {task.priority}
                          </span>
                        </div>
                        <div className="flex items-center mt-2 space-x-3 text-sm text-gray-500">
                          <Users className="h-4 w-4" /> {task.assignee}
                          <Clock className="h-4 w-4 ml-2" /> {task.deadline}
                          <div className="flex items-center space-x-1">
                            <MessageCircle className="h-3 w-3" /> {task.comments}
                            <FileText className="h-3 w-3 ml-1" /> {task.attachments}
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              ))}
            </div>
          </TabsContent>

          {/* Timeline / Gantt (placeholder) */}
          <TabsContent value="timeline" className="space-y-4">
            <Card className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle>Timeline / Gantt</CardTitle>
                <CardDescription>
                  Vue chronologique des projets avec jalons, dépendances et avancement des tâches.
                </CardDescription>
              </CardHeader>
              <CardContent className="pt-0">
                <div className="h-96 bg-gray-50 rounded-lg flex items-center justify-center text-gray-400">
                  Timeline view (to be implemented with a Gantt library)
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Tâches */}
          <TabsContent value="taches" className="space-y-4">
            <Card className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle>Liste des tâches</CardTitle>
                <CardDescription>
                  Toutes les tâches du projet sélectionné avec sous-tâches, assignation et suivi.
                </CardDescription>
              </CardHeader>
              {selectedProject ? (
                <CardContent className="space-y-4">
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Titre</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Responsable</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Deadline</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priorité</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Temps estimé</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Temps réel</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-200">
                        {/* Dummy rows */}
                        {[...Array(5)].map((_, i) => (
                          <tr key={i} className="hover:bg-gray-50 transition-background">
                            <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              Tâche exemple {i + 1}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              Utilisateur {i + 1}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              2026-05-{20 + i}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap">
                              <span className={`px-2 py-0.5 text-xs rounded ${
                                i % 4 === 0 ? 'bg-green-100 text-green-800' :
                                i % 4 === 1 ? 'bg-yellow-100 text-yellow-800' :
                                i % 4 === 2 ? 'bg-orange-100 text-orange-800' :
                                'bg-red-100 text-red-800'
                              }`}>
                                {['Faible', 'Moyenne', 'Haute', 'Urgente'][i % 4]}
                              </span>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm">
                              <span className={`px-2 py-0.5 text-xs rounded ${
                                i % 3 === 0 ? 'bg-green-100 text-green-800' :
                                i % 3 === 1 ? 'bg-yellow-100 text-yellow-800' :
                                'bg-red-100 text-red-800'
                              }`}>
                                {['À faire', 'En cours', 'Terminé'][i % 3]}
                              </span>
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              4h
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              3h
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                              <Button variant="ghost" size="sm">Modifier</Button>
                              <Button variant="destructive" ghost size="sm">Supprimer</Button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </CardContent>
              ) : (
                <CardContent className="text-center py-8 text-gray-500">
                  Sélectionnez un projet pour voir ses tâches
                </CardContent>
              )}
            </Card>
          </TabsContent>

          {/* Équipe & Collaboration */}
          <TabsContent value="equipe" className="space-y-4">
            <div className="grid gap-4">
              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Membres du projet</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {selectedProject ? (
                    <div>
                      {selectedProject.members.map((m, i) => (
                        <motion.key
                          key={i}
                          initial={{ x: -10, opacity: 0 }}
                          animate={{ x: 0, opacity: 1 }}
                          transition={{ delay: i * 0.03, duration: 0.4 }}
                        >
                          <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                            <div className="relative h-10 w-10">
                              <img src="https://via.placeholder.com/40" alt={m} className="object-cover w-full h-full rounded-full" />
                              <div className="absolute -bottom-1 -right-1 h-2 w-2 bg-green-500 rounded-full border-2 border-white"></div>
                            </div>
                            <div>
                              <p className="font-medium text-gray-900">{m}</p>
                              <p className="text-xs text-gray-500">Développeur senior</p>
                            </div>
                          </div>
                        </motion.key>
                      ))}
                    </div>
                  ) : (
                    <p className="text-center py-4 text-gray-500">Aucun projet sélectionné</p>
                  )}
                </CardContent>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Activité récente</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {[...Array(4)].map((_, i) => (
                    <motion.key
                      key={i}
                      initial={{ y: 10, opacity: 0 }}
                      animate={{ y: 0, opacity: 1 }}
                      transition={{ delay: i * 0.04, duration: 0.4 }}
                    >
                      <div className="flex items-start space-x-3 p-3 border-b border-gray-100 last:border-b-0">
                        <div className="flex-shrink-0 h-8 w-8 bg-purple-100 rounded-full flex items-center justify-center">
                          <Bell className="h-4 w-4 text-purple-600" />
                        </div>
                        <div className="flex-1 space-y-1">
                          <p className="text-sm font-medium text-gray-900">
                            Utilisateur a modifié la tâche "Exemple de tâche"
                          </p>
                          <p className="text-xs text-gray-500">
                            Il y a {i + 1} heure{s === 1 ? '' : 's'}
                          </p>
                        </div>
                      </div>
                    </motion.key>
                  ))}
                </CardContent>
              </div>
            </div>
          </TabsContent>

          {/* Analytics & Performance */}
          <TabsContent value="analytics" className="space-y-4">
            <div className="grid gap-4">
              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Progression des projets</CardTitle>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={200}>
                    <BarChart data={analyticsData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="name" />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Bar dataKey="projets" label="Projets" fill="#8b5cf6" />
                      <Bar dataKey="taches" label="Tâches" fill="#ec4899" />
                    </BarChart>
                  </ResponsiveContainer>
                </CardContent>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Productivité équipe</CardTitle>
                </CardHeader>
                <CardContent className="flex items-center space-x-4">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-purple-600">+12%</div>
                    <p className="text-sm text-gray-500">vs mois précédent</p>
                  </div>
                  <div className="flex-1">
                    <div className="w-full bg-gray-200 rounded-full h-2.5 mt-2">
                      <div className="bg-purple-600 h-2.5 rounded-full" style={{ width: '60%' }}></div>
                    </div>
                    <p className="text-xs text-gray-500 mt-1">Capacité utilisée</p>
                  </div>
                </CardContent>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Respect des deadlines</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between text-sm">
                      <span>Tâches à temps</span>
                      <span className="font-medium text-green-600">78%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2.5">
                      <div className="bg-green-500 h-2.5 rounded-full" style={{ width: '78%' }}></div>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span>Tâches en retard</span>
                      <span className="font-medium text-red-600">22%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2.5">
                      <div className="bg-red-500 h-2.5 rounded-full" style={{ width: '22%' }}></div>
                    </div>
                  </div>
                </CardContent>
              </div>
            </div>
          </TabsContent>

          {/* Calendrier */}
          <TabsContent value="calendrier" className="space-y-4">
            <Card className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle>Calendrier des deadlines</CardTitle>
              </CardHeader>
              <CardContent className="pt-0">
                <div className="h-[500px] bg-gray-50 rounded-lg flex items-center justify-center text-gray-400">
                  Calendar view (to be implemented with a calendar library)
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Notifications */}
          <TabsContent value="notifications" className="space-y-4">
            <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle>Notifications</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 max-h-[400px] overflow-y-auto pr-2">
                {[...Array(6)].map((_, i) => (
                  <motion.key
                    key={i}
                    initial={{ y: 10, opacity: 0 }}
                    animate={{ y: 0, opacity: 1 }}
                    transition={{ delay: i * 0.03, duration: 0.4 }}
                  >
                    <div className="flex items-start space-x-3 p-3 border-b border-gray-100 last:border-b-0">
                      <div className="flex-shrink-0 h-8 w-8 bg-purple-100 rounded-full flex items-center justify-center">
                        {i % 2 === 0 ? (
                          <Bell className="h-4 w-4 text-purple-600" />
                        ) : (
                          <MessageCircle className="h-4 w-4 text-purple-600" />
                        )}
                      </div>
                      <div className="flex-1 space-y-1">
                        <p className="text-sm font-medium text-gray-900">
                          {i % 2 === 0 ? 'Deadline approchant' : 'Nouveau commentaire sur tâche'}
                        </p>
                        <p className="text-xs text-gray-500">
                          Il y a {i + 1} heure{s === 1 ? '' : 's'}
                        </p>
                      </div>
                    </div>
                  </motion.key>
                )}
              </CardContent>
            </div>
          </TabsContent>

          {/* Fichiers & Documents */}
          <TabsContent value="fichiers" className="space-y-4">
            <div className="grid gap-4">
              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Upload de fichiers</CardTitle>
                </CardHeader>
                <CardContent className="flex flex-col items-center pt-8 pb-4">
                  <div className="flex flex-col items-center space-y-4">
                    <div className="h-12 w-12 bg-purple-100 rounded-lg flex items-center justify-center">
                      <Upload className="h-6 w-6 text-purple-500" />
                    </div>
                    <p className="text-center text-sm text-gray-500">
                      Glissez-déposez vos fichiers ici ou
                    </p>
                    <Button variant="outline" size="sm">Parcourir les fichiers</p>
                  </div>
                  <p className="text-xs text-gray-400 text-center mt-2">
                    Formats supportés : PDF, DOC, XLS, JPG, PNG (max 100 Mo)
                  </p>
                </CardContent>
              </div>

              <div className="bg-white rounded-xl border border-gray-100 shadow-sm">
                <CardHeader>
                  <CardTitle>Documents récents</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {[...Array(4)].map((_, i) => (
                    <motion.key
                      key={i}
                      initial={{ x: -10, opacity: 0 }}
                      animate={{ x: 0, opacity: 1 }}
                      transition={{ delay: i * 0.04, duration: 0.4 }}
                    >
                      <div className="flex items-start space-x-3 p-3 border-b border-gray-100 last:border-b-0">
                        <div className="flex-shrink-0 h-9 w-9 bg-gray-100 rounded-lg flex items-center justify-center">
                          <FileText className="h-4 w-4 text-gray-500" />
                        </div>
                        <div className="flex-1 space-y-1">
                          <p className="text-sm font-medium text-gray-900 line-clamp-1">
                            Document exemple {i + 1}.pdf
                          </p>
                          <p className="text-xs text-gray-500">
                            {i + 1} Mo • Modifié il y a {(i + 1) * 2} heures
                          </p>
                        </div>
                        <div className="flex-shrink-0 text-right">
                          <Button variant="ghost" size="sm" className="p-1">
                            <Download className="h-4 w-4 text-gray-400" />
                          </Button>
                        </div>
                      </div>
                    </motion.key>
                  ))}
                </CardContent>
              </div>
            </div>
          </TabsContent>

          {/* Clients */}
          <TabsContent value="clients" className="space-y-4">
            <Card className="bg-white rounded-xl border border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle>Informations client</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4">
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900">NexaCorp Inc.</h3>
                    <p className="mt-1 text-sm text-gray-500">
                      Client depuis mars 2026 • Abonnement Entreprise
                    </p>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900">Avancement visible client</h3>
                    <div className="mt-2">
                      <div className="flex items-center justify-between text-sm">
                        <span>Projet principal</span>
                        <span className="font-medium text-blue-600">65%</span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div className="bg-blue-500 h-2 rounded" style={{ width: '65%' }}></div>
                      </div>
                    </div>
                  </div>
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <h3 className="font-semibold text-gray-900">Feedback client</h3>
                    <div className="space-y-2">
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0 h-8 w-8 bg-green-100 rounded-full flex items-center justify-center">
                          <CheckCircle className="h-4 w-4 text-green-600" />
                        </div>
                        <div>
                          <p className="text-sm font-medium text-gray-900">
                            "Très satisfait de la progression actuelle"
                          </p>
                          <p className="text-xs text-gray-500">
                            Il y a 2 jours
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </motion.div>
    </div>
  );
}