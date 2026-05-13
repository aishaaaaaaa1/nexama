import React from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import ProjectTrackingPageWrapper from "./pages/ProjectTracking.jsx";
import { Toaster } from "react-hot-toast";

createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <ProjectTrackingPageWrapper />
    <Toaster position="top-right" />
  </React.StrictMode>
);
