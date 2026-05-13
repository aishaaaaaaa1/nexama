import React, { createContext, useContext, useEffect, useState } from "react";
import { v4 as uuid } from "uuid";
import { formatISO } from "date-fns";

const STORAGE_KEY = "nexama.projects.v1";
const ProjectsContext = createContext(null);

const sampleData = () => ({
  projects: [
    {
      id: "proj-1",
      name: "Refonte site web",
      description: "Revoir UI/UX et performance",
      status: "active",
      priority: "High",
      deadline: formatISO(new Date(Date.now() + 7 * 24 * 3600 * 1000)),
      members: [{ id: "u1", name: "Alice" }, { id: "u2", name: "Marc" }],
      tags: ["UI", "Performance"],
      progress: 45,
      lastActivity: formatISO(new Date()),
      tasks: [
        { id: "t1", title: "Audit performance", status: "todo", assignee: "u1", priority: "Medium", due: null, completed: false, comments: [] },
        { id: "t2", title: "Maquette nouvelle page", status: "inprogress", assignee: "u2", priority: "High", due: null, completed: false, comments: [] }
      ]
    },
    {
      id: "proj-2",
      name: "API v2",
      description: "Endpoints optimisés",
      status: "completed",
      priority: "Medium",
      deadline: formatISO(new Date(Date.now() - 2 * 24 * 3600 * 1000)),
      members: [{ id: "u3", name: "Sophie" }],
      tags: ["Backend"],
      progress: 100,
      lastActivity: formatISO(new Date(Date.now() - 86400000)),
      tasks: []
    }
  ],
  members: [
    { id: "u1", name: "Alice", online: true },
    { id: "u2", name: "Marc", online: true },
    { id: "u3", name: "Sophie", online: false }
  ],
  notifications: []
});

export function ProjectsProvider({ children }) {
  const [state, setState] = useState(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : sampleData();
    } catch {
      return sampleData();
    }
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [state]);

  const addProject = (payload) => {
    const project = {
      id: uuid(),
      name: payload.name,
      description: payload.description || "",
      status: "active",
      priority: payload.priority || "Medium",
      deadline: payload.deadline || null,
      members: payload.members || [],
      tags: payload.tags || [],
      progress: 0,
      lastActivity: formatISO(new Date()),
      tasks: []
    };
    setState((s) => ({ ...s, projects: [project, ...s.projects] }));
    return project;
  };

  const updateProject = (id, patch) => {
    setState((s) => ({
      ...s,
      projects: s.projects.map((p) => (p.id === id ? { ...p, ...patch, lastActivity: formatISO(new Date()) } : p))
    }));
  };

  const deleteProject = (id) => setState((s) => ({ ...s, projects: s.projects.filter((p) => p.id !== id) }));

  const duplicateProject = (id) => {
    setState((s) => {
      const original = s.projects.find((p) => p.id === id);
      if (!original) return s;
      const copy = { ...original, id: uuid(), name: original.name + " (copie)", lastActivity: formatISO(new Date()) };
      return { ...s, projects: [copy, ...s.projects] };
    });
  };

  const addTask = (projectId, task) => {
    setState((s) => ({
      ...s,
      projects: s.projects.map((p) =>
        p.id === projectId ? { ...p, tasks: [{ id: uuid(), completed: false, status: "todo", comments: [], ...task }, ...p.tasks] } : p
      )
    }));
  };

  const updateTask = (projectId, taskId, patch) => {
    setState((s) => ({
      ...s,
      projects: s.projects.map((p) =>
        p.id === projectId ? { ...p, tasks: p.tasks.map((t) => (t.id === taskId ? { ...t, ...patch } : t)) } : p
      )
    }));
  };

  const removeTask = (projectId, taskId) => {
    setState((s) => ({
      ...s,
      projects: s.projects.map((p) => (p.id === projectId ? { ...p, tasks: p.tasks.filter((t) => t.id !== taskId) } : p))
    }));
  };

  const moveTaskBetween = (fromProjId, toProjId, taskId, newStatus, index = 0) => {
    setState((s) => {
      const from = s.projects.find((p) => p.id === fromProjId);
      const to = s.projects.find((p) => p.id === toProjId);
      if (!from || !to) return s;
      const task = from.tasks.find((t) => t.id === taskId);
      if (!task) return s;
      const newTask = { ...task, status: newStatus, lastActivity: formatISO(new Date()) };
      return {
        ...s,
        projects: s.projects.map((p) => {
          if (p.id === fromProjId) return { ...p, tasks: p.tasks.filter((t) => t.id !== taskId) };
          if (p.id === toProjId) {
            const nt = [...p.tasks];
            nt.splice(index, 0, newTask);
            return { ...p, tasks: nt };
          }
          return p;
        })
      };
    });
  };

  const getStats = () => {
    const total = state.projects.length;
    const active = state.projects.filter((p) => p.status === "active").length;
    const completed = state.projects.filter((p) => p.status === "completed").length;
    const overdueTasks = state.projects.flatMap((p) => p.tasks).filter((t) => t.due && new Date(t.due) < new Date() && !t.completed).length;
    const avgProgress = state.projects.length ? Math.round(state.projects.reduce((acc, p) => acc + (p.progress || 0), 0) / state.projects.length) : 0;
    const productivity = Math.min(100, avgProgress + Math.round(Math.random() * 10));
    const membersActive = state.members.filter((m) => m.online).length;
    const avgTime = Math.round(2 + Math.random() * 5);
    return { total, active, completed, overdueTasks, avgProgress, productivity, membersActive, avgTime };
  };

  const exportJSON = () => ({ ...state });

  return (
    <ProjectsContext.Provider
      value={{
        state,
        addProject,
        updateProject,
        deleteProject,
        duplicateProject,
        addTask,
        updateTask,
        removeTask,
        moveTaskBetween,
        getStats,
        exportJSON
      }}
    >
      {children}
    </ProjectsContext.Provider>
  );
}

export const useProjects = () => useContext(ProjectsContext);
export default ProjectsContext;