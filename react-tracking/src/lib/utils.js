import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export const priorityColor = (prio) => {
  switch (prio) {
    case "Faible": case "Low": return "bg-gray-100 text-gray-600";
    case "Moyenne": case "Medium": return "bg-amber-50 text-amber-700 border border-amber-200";
    case "Haute": case "High": return "bg-orange-50 text-orange-700 border border-orange-200";
    case "Urgente": case "Urgent": return "bg-red-50 text-red-700 border border-red-200";
    default: return "bg-gray-100 text-gray-600";
  }
};

export const statusColor = (status) => {
  switch (status) {
    case "active": case "en_cours": return "bg-blue-50 text-blue-700 border border-blue-200";
    case "en_attente": return "bg-amber-50 text-amber-700 border border-amber-200";
    case "completed": case "termine": return "bg-emerald-50 text-emerald-700 border border-emerald-200";
    case "annule": return "bg-gray-100 text-gray-500 border border-gray-200";
    default: return "bg-gray-100 text-gray-600";
  }
};

export const statusLabel = (status) => {
  switch (status) {
    case "active": case "en_cours": return "En cours";
    case "en_attente": return "En attente";
    case "completed": case "termine": return "Terminé";
    case "annule": return "Annulé";
    default: return status;
  }
};

export function formatTimeLeft(date) {
  if (!date) return "—";
  const now = new Date();
  const target = new Date(date);
  const diff = target - now;
  if (diff < 0) return "En retard";
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  if (days > 30) return `${Math.floor(days / 30)} mois`;
  if (days > 0) return `${days}j restants`;
  const hours = Math.floor(diff / (1000 * 60 * 60));
  if (hours > 0) return `${hours}h restantes`;
  return "< 1h";
}

export const memberColors = [
  "bg-violet-500", "bg-emerald-500", "bg-amber-500", "bg-rose-500",
  "bg-cyan-500", "bg-indigo-500", "bg-pink-500", "bg-teal-500",
];

export const kanbanColumns = [
  { id: "todo", label: "À faire", color: "bg-gray-400" },
  { id: "inprogress", label: "En cours", color: "bg-blue-500" },
  { id: "inreview", label: "En révision", color: "bg-amber-500" },
  { id: "done", label: "Terminé", color: "bg-emerald-500" },
];
