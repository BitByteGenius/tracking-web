import express from "express";
import {
  authCreateController,
  authLoginController,
  adminLoginController,
} from "../controllers/auth.controller.js";

const router = express.Router();

// User registration — POST /api/auth/register
router.post("/register", authCreateController);

// User login (email + password) — POST /api/auth/login
router.post("/login", authLoginController);

// Admin login (.env credentials only, no DB) — POST /api/auth/admin-login
router.post("/admin-login", adminLoginController);

export default router;
