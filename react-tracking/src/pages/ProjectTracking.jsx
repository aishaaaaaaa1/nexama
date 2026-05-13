import React, { useMemo, useState } from "react";
import { useProjects, ProjectsProvider } from "../context/projectsContext";
import { saveAs } from "file-saver";
import { DragDropContext, Droppable, Draggable } from "react-beautiful-dnd";
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, BarChart, Bar } from "recharts";
import { motion, AnimatePresence } from "framer-motion";
import { format, formatDistanceToNow } from "date-fns";
import toast from "react-hot-toast";

function Header({ onNew, onExport, view, setView, q, setQ }) {
  return (
    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
      <div>
        <h1 className="text-2xl font-semibold text-gray-800">Suivi de Projet</h1>
        <p className="text-sm text-gray-500">Suivez l'avancement des projets, tâches et performances en temps réel.</p>
      </div>
      <div className="flex gap-3 items-center">
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Rechercher projets, membres, tags..." className="px-3 py-2 rounded-lg border bg-white shadow-sm w-64" />
        <select value={view} onChange={(e) => setView(e.target.value)} className="px-3 py-2 rounded-lg border bg-white shadow-sm">
          <option value="list">Liste</option>
          <option value="kanban">Kanban</option>
          <option value="timeline">Timeline</option>
          <option value="calendar">Calendrier</option>
        </select>
        <button onClick={onExport} className="bg-violet-600 text-white px-4 py-2 rounded-lg shadow hover:brightness-105">Exporter</button>
        <button onClick={onNew} className="bg-white border border-violet-600 text-violet-600 px-4 py-2 rounded-lg shadow">+ Nouveau Projet</button>
      </div>
    </div>
  );
}

function StatGrid({ stats }) {
  const spark = [
    { name: "W1", v: stats.avgProgress * 0.6 },
    { name: "W2", v: stats.avgProgress * 0.8 },
    { name: "W3", v: stats.avgProgress * 0.9 },
    { name: "W4", v: stats.avgProgress }
  ];
  return (
    <div className="grid grid-cols-2 md:grid-cols-8 gap-4 mb-6">
      <div className="p-4 rounded-xl bg-white shadow glass col-span-2">
        <div className="text-sm text-gray-500">Projets</div>
        <div className="text-xl font-semibold">{stats.total}</div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass">
        <div className="text-sm text-gray-500">Actifs</div>
        <div className="text-xl font-semibold">{stats.active}</div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass">
        <div className="text-sm text-gray-500">Terminés</div>
        <div className="text-xl font-semibold">{stats.completed}</div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass">
        <div className="text-sm text-gray-500">Retards</div>
        <div className="text-xl font-semibold">{stats.overdueTasks}</div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass col-span-2">
        <div className="text-sm text-gray-500">Progression moyenne</div>
        <div className="flex items-center justify-between">
          <div className="text-xl font-semibold">{stats.avgProgress}%</div>
          <div className="w-36 h-12">
            <ResponsiveContainer width="100%" height="100%"><LineChart data={spark}><Line type="monotone" dataKey="v" stroke="#7c3aed" strokeWidth={2} dot={false} /><XAxis dataKey="name" hide /><YAxis hide /><Tooltip /></LineChart></ResponsiveContainer>
          </div>
        </div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass">
        <div className="text-sm text-gray-500">Membres actifs</div>
        <div className="text-xl font-semibold">{stats.membersActive}</div>
      </div>
      <div className="p-4 rounded-xl bg-white shadow glass">
        <div className="text-sm text-gray-500">Temps moyen (jours)</div>
        <div className="text-xl font-semibold">{stats.avgTime}</div>
      </div>
    </div>
  );
}

function ProjectCard({ p, onEdit, onDelete, onDuplicate, onOpen }) {
  const timeLeft = p.deadline ? formatDistanceToNow(new Date(p.deadline), { addSuffix: true }) : "—";
  const priorityColor = (prio) => {
    switch (prio) {
      case "Low": return "bg-green-100 text-green-700";
      case "Medium": return "bg-yellow-100 text-yellow-700";
      case "High": return "bg-orange-100 text-orange-700";
      case "Urgent": return "bg-red-100 text-red-700";
      default: return "bg-gray-100 text-gray-700";
    }
  };

  return (
    <motion.div layout className="p-4 bg-white rounded-xl shadow flex justify-between items-center">
      <div>
        <div className="flex items-center gap-3">
          <div className="text-lg font-semibold">{p.name}</div>
          <div className="text-xs px-2 py-1 rounded {p.status === 'completed' ? 'bg-green-50' : 'bg-gray-100'} text-gray-600">{p.status}</div>
          {p.tags && p.tags.map((t) => (<div key={t} className="text-xs px-2 py-1 rounded bg-violet-50 text-violet-700">{t}</div>))}
        </div>
        <div className="text-sm text-gray-500">{p.description}</div>
        <div className="text-xs text-gray-400 mt-2">Deadline: {p.deadline ? format(new Date(p.deadline), "yyyy-MM-dd") : "—"} • {timeLeft} • Dernière activité: {format(new Date(p.lastActivity), "yyyy-MM-dd")}</div>
      </div>
      <div className="flex items-center gap-3">
        <div className="w-40">
          <div className="text-xs text-gray-500">Progression</div>
          <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
            <div className="h-full bg-violet-600" style={{ width: `${p.progress}%` }} />
          </div>
        </div>
        <div className={`text-xs px-2 py-1 rounded ${priorityColor(p.priority)}`}>{p.priority}</div>
        <button onClick={() => onOpen(p)} className="px-3 py-2 text-sm rounded border">Ouvrir</button>
        <button onClick={() => onEdit(p)} className="px-3 py-2 text-sm rounded bg-white border">Modifier</button>
        <button onClick={() => onDuplicate(p.id)} className="px-3 py-2 text-sm rounded bg-gray-50 border">Dupliquer</button>
        <button onClick={() => onDelete(p.id)} className="px-3 py-2 text-sm rounded bg-red-50 text-red-600 border">Supprimer</button>
      </div>
    </motion.div>
  );
}

function ProjectList({ projects, onEdit, onDelete, onDuplicate, onOpen }) {
  if (!projects.length) return <div className="p-6 bg-white rounded-xl shadow">Aucun projet trouvé.</div>;
  return (
    <div className="space-y-4">
      {projects.map((p) => (
        <ProjectCard key={p.id} p={p} onEdit={onEdit} onDelete={onDelete} onDuplicate={onDuplicate} onOpen={onOpen} />
      ))}
    </div>
  );
}

function KanbanBoard({ projects, moveTaskBetween, openTask }) {
  const columns = ["todo", "inprogress", "inreview", "done"];
  const colLabel = (c) => ({ todo: "À faire", inprogress: "En cours", inreview: "En révision", done: "Terminé" }[c]);

  // flatten tasks across projects
  const colMap = columns.reduce((acc, c) => ({ ...acc, [c]: projects.flatMap((p) => p.tasks.filter((t) => t.status === c).map((t) => ({ ...t, projectId: p.id, projectName: p.name })) ) }), {});

  const onDragEnd = (result) => {
    if (!result.destination) return;
    const { source, destination, draggableId } = result;
    const [projectId, taskId] = draggableId.split("|");
    const fromCol = source.droppableId;
    const toCol = destination.droppableId;
    if (fromCol === toCol) return; // reorder not implemented
    moveTaskBetween(projectId, projectId, taskId, toCol);
    toast.success("Tâche déplacée");
  };

  return (
    <DragDropContext onDragEnd={onDragEnd}>
      <div className="flex gap-4 overflow-auto">
        {columns.map((col) => (
          <div key={col} className="min-w-[260px] bg-white rounded-xl p-3 shadow">
            <div className="text-sm font-medium mb-2">{colLabel(col)} ({colMap[col].length})</div>
            <Droppable droppableId={col}>
              {(provided) => (
                <div ref={provided.innerRef} {...provided.droppableProps} className="space-y-3 min-h-[200px]">
                  {colMap[col].map((task, idx) => (
                    <Draggable key={`${task.projectId}|${task.id}`} draggableId={`${task.projectId}|${task.id}`} index={idx}>
                      {(prov) => (
                        <div ref={prov.innerRef} {...prov.draggableProps} {...prov.dragHandleProps} className="p-3 rounded-lg bg-gray-50 cursor-grab">
                          <div className="font-medium">{task.title}</div>
                          <div className="text-xs text-gray-500">{task.projectName} • {task.assignee || '—'}</div>
                          <div className="flex items-center justify-between mt-2">
                            <div className="text-xs text-gray-400">{task.priority}</div>
                            <div className="text-xs text-violet-600 cursor-pointer" onClick={() => openTask(task.projectId, task.id)}>Détails</div>
                          </div>
                        </div>
                      )}
                    </Draggable>
                  ))}
                  {provided.placeholder}
                </div>
              )}
            </Droppable>
          </div>
        ))}
      </div>
    </DragDropContext>
  );
}

function CreateProjectModal({ open, onClose, onCreate }) {
  const [name, setName] = useState("");
  const [desc, setDesc] = useState("");
  const submit = () => {
    if (!name.trim()) return toast.error("Nom requis");
    onCreate({ name, description: desc });
    setName(""); setDesc("");
    onClose();
    toast.success("Projet créé");
  };
  return (
    <AnimatePresence>
      {open && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <motion.div initial={{ y: -10 }} animate={{ y: 0 }} exit={{ y: -10 }} className="bg-white rounded-xl p-6 w-full max-w-md shadow-lg">
            <h3 className="text-lg font-semibold mb-2">Nouveau projet</h3>
            <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Nom du projet" className="w-full mb-2 p-2 border rounded" />
            <textarea value={desc} onChange={(e) => setDesc(e.target.value)} placeholder="Description" className="w-full mb-4 p-2 border rounded" />
            <div className="flex justify-end gap-2">
              <button onClick={onClose} className="px-3 py-2 rounded border">Annuler</button>
              <button onClick={submit} className="px-3 py-2 rounded bg-violet-600 text-white">Créer</button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

function ProjectDetailsModal({ open, onClose, project, onAddTask, onUpdateTask, onDeleteTask }) {
  const [taskTitle, setTaskTitle] = useState("");
  const [assignee, setAssignee] = useState("");
  const [priority, setPriority] = useState("Medium");
  const submitTask = () => {
    if (!taskTitle.trim()) return toast.error("Titre requis");
    onAddTask(project.id, { title: taskTitle, assignee, priority, due: null });
    setTaskTitle(""); setAssignee(""); setPriority("Medium");
    toast.success("Tâche ajoutée");
  };

  if (!project) return null;
  return (
    <AnimatePresence>
      {open && (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <motion.div initial={{ y: -10 }} animate={{ y: 0 }} exit={{ y: -10 }} className="bg-white rounded-xl p-6 w-full max-w-3xl shadow-lg overflow-auto max-h-[90vh]">
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-semibold mb-1">{project.name}</h3>
                <div className="text-sm text-gray-500">{project.description}</div>
              </div>
              <div className="text-sm text-gray-400">Dernière activité: {format(new Date(project.lastActivity), "yyyy-MM-dd")}</div>
            </div>
            <div className="mt-4 grid md:grid-cols-2 gap-4">
              <div>
                <h4 className="font-medium mb-2">Tâches</h4>
                <div className="space-y-2">
                  {project.tasks.map((t) => (
                    <div key={t.id} className="p-3 bg-gray-50 rounded-lg flex justify-between items-center">
                      <div>
                        <div className="font-medium">{t.title}</div>
                        <div className="text-xs text-gray-500">{t.assignee || '—'} • {t.priority}</div>
                      </div>
                      <div className="flex gap-2">
                        <button onClick={() => onUpdateTask(project.id, t.id, { completed: !t.completed })} className="px-2 py-1 text-sm rounded border">{t.completed ? 'Rouvrir' : 'Terminer'}</button>
                        <button onClick={() => onDeleteTask(project.id, t.id)} className="px-2 py-1 text-sm rounded bg-red-50 text-red-600 border">Supprimer</button>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-4 p-3 bg-gray-100 rounded">
                  <input value={taskTitle} onChange={(e) => setTaskTitle(e.target.value)} placeholder="Titre tâche" className="w-full mb-2 p-2 rounded border" />
                  <div className="flex gap-2 mb-2">
                    <select value={assignee} onChange={(e) => setAssignee(e.target.value)} className="p-2 rounded border w-1/2">
                      <option value="">Assigner à...</option>
                      {project.members.map((m) => <option key={m.id} value={m.id}>{m.name}</option>)}
                    </select>
                    <select value={priority} onChange={(e) => setPriority(e.target.value)} className="p-2 rounded border w-1/2">
                      <option>Low</option>
                      <option>Medium</option>
                      <option>High</option>
                      <option>Urgent</option>
                    </select>
                  </div>
                  <div className="flex justify-end gap-2">
                    <button onClick={submitTask} className="px-3 py-2 rounded bg-violet-600 text-white">Ajouter tâche</button>
                  </div>
                </div>
              </div>
              <div>
                <h4 className="font-medium mb-2">Détails</h4>
                <div className="p-3 bg-gray-50 rounded">
                  <div className="text-sm text-gray-500 mb-2">Membres</div>
                  <div className="flex gap-2 flex-wrap">
                    {project.members.map((m) => <div key={m.id} className="px-2 py-1 bg-white rounded shadow-sm text-sm">{m.name}</div>)}
                  </div>
                </div>
                <div className="mt-4 p-3 bg-gray-50 rounded">
                  <div className="text-sm text-gray-500 mb-2">Tags</div>
                  <div className="flex gap-2 flex-wrap">{project.tags.map((t) => <div key={t} className="px-2 py-1 bg-violet-50 text-violet-700 rounded text-sm">{t}</div>)}</div>
                </div>
              </div>
            </div>
            <div className="flex justify-end mt-4">
              <button onClick={onClose} className="px-3 py-2 rounded border">Fermer</button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

export default function ProjectTrackingPageWrapper() {
  return (
    <ProjectsProvider>
      <ProjectTrackingPage />
    </ProjectsProvider>
  );
}

function ProjectTrackingPage() {
  const { state, addProject, updateProject, deleteProject, duplicateProject, addTask, updateTask, removeTask, moveTaskBetween, getStats, exportJSON } = useProjects();
  const [view, setView] = useState("list");
  const [q, setQ] = useState("");
  const [createOpen, setCreateOpen] = useState(false);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [activeProject, setActiveProject] = useState(null);

  const stats = useMemo(() => getStats(), [state]);

  const onExport = () => {
    const blob = new Blob([JSON.stringify(exportJSON(), null, 2)], { type: "application/json" });
    saveAs(blob, `nexama-export-${new Date().toISOString()}.json`);
    toast.success("Export fait");
  };

  const filtered = state.projects.filter((p) => {
    const qq = q.trim().toLowerCase();
    if (!qq) return true;
    return [p.name, p.description, p.status, p.priority, ...(p.tags || [])].join(" ").toLowerCase().includes(qq) || (p.members || []).some((m) => m.name.toLowerCase().includes(qq));
  });

  const handleCreate = (payload) => addProject(payload);
  const handleEdit = (p) => {
    const newName = prompt("Modifier le nom", p.name);
    if (newName) updateProject(p.id, { name: newName });
  };

  const handleOpen = (p) => { setActiveProject(p); setDetailsOpen(true); };

  const handleAddTask = (projectId, task) => {
    addTask(projectId, task);
    // recompute progress
    const proj = state.projects.find((x) => x.id === projectId);
    if (proj) {
      const total = proj.tasks.length + 1; // optimistic
      const done = proj.tasks.filter((t) => t.completed).length;
      const progress = Math.round((done / total) * 100);
      updateProject(projectId, { progress });
    }
  };

  const handleUpdateTask = (projectId, taskId, patch) => {
    updateTask(projectId, taskId, patch);
    // update project progress
    const proj = state.projects.find((x) => x.id === projectId);
    if (proj) {
      const tasks = proj.tasks.map((t) => (t.id === taskId ? { ...t, ...patch } : t));
      const total = tasks.length;
      const done = tasks.filter((t) => t.completed).length;
      const progress = total ? Math.round((done / total) * 100) : 0;
      updateProject(projectId, { progress });
    }
  };

  const handleDeleteTask = (projectId, taskId) => {
    removeTask(projectId, taskId);
    toast.success("Tâche supprimée");
  };

  return (
    <div className="p-6 min-h-screen bg-gray-50">
      <Header onNew={() => setCreateOpen(true)} onExport={onExport} view={view} setView={setView} q={q} setQ={setQ} />
      <StatGrid stats={stats} />

      <div className="mb-6">
        {view === "list" && <ProjectList projects={filtered} onEdit={handleEdit} onDelete={(id) => { if (confirm('Supprimer ce projet ?')) { deleteProject(id); toast.success('Projet supprimé'); } }} onDuplicate={(id) => { duplicateProject(id); toast.success('Projet dupliqué'); }} onOpen={handleOpen} />}
        {view === "kanban" && <KanbanBoard projects={filtered} moveTaskBetween={moveTaskBetween} openTask={(projId, taskId) => { const proj = state.projects.find(p => p.id === projId); const t = proj?.tasks.find(tt => tt.id === taskId); setActiveProject(proj); setDetailsOpen(true); }} />}
        {view === "timeline" && <div className="p-6 bg-white rounded-xl shadow">Timeline (à intégrer : Gantt/Timeline)</div>}
        {view === "calendar" && <div className="p-6 bg-white rounded-xl shadow">Calendrier (à intégrer : react-big-calendar)</div>}
      </div>

      <CreateProjectModal open={createOpen} onClose={() => setCreateOpen(false)} onCreate={handleCreate} />
      <ProjectDetailsModal open={detailsOpen} onClose={() => setDetailsOpen(false)} project={activeProject} onAddTask={handleAddTask} onUpdateTask={handleUpdateTask} onDeleteTask={handleDeleteTask} />
    </div>
  );
}
