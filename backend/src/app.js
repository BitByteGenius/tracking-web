import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth.routes.js";
import trackingRoutes from "./routes/tracking.route.js";

// For attendance routes, we need to import the attendanceRoutes module and use it in the app. 
import attendanceRoutes from "./routes/attendance.route.js";

const app = express();

// ─── Global Middleware ──────────────────────────────────────────────────────
// Must be registered BEFORE routes so request bodies are parsed correctly.
app.use(cors({
  origin: "*",
  credentials: true,
}));

app.options("*", cors({
  origin: "*",
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// ─── Routes ────────────────────────────────────────────────────────────────
// Use the attendanceRoutes for all routes starting with /api/attendance
app.use("/api/attendance", attendanceRoutes);

// ─── Routes ────────────────────────────────────────────────────────────────
// Auth routes were missing — login/register returned 404 before this fix.
app.use("/api/auth", authRoutes);
app.use("/api/tracking", trackingRoutes);

// ─── Health Check ──────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.json({ message: "Live Tracking API is running 🚀" });
});

// ─── 404 Handler ───────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
});

// ─── Centralized Error Handler ─────────────────────────────────────────────
// Catches errors from next(error) calls — never exposes stack traces to client.
app.use((err, req, res, _next) => {
  console.error("❌ Unhandled Error:", err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
});

export default app;
