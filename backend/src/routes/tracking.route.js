import express from "express";
import protect from "../middleware/protect.js";
import adminOnly from "../middleware/admin.middleware.js";
import upload from "../middleware/upload.middleware.js";

import {
  startTracking,
  updateTracking,
  stopTracking,
  getMyStatus,
  getAllTracking,
} from "../controllers/tracking.controller.js";

const router = express.Router();

// ==========================
// CHECK IN
// ==========================
router.post(
  "/start",
  protect,
  upload.single("photo"),
  startTracking
);

// ==========================
// LIVE LOCATION UPDATE
// ==========================
router.put(
  "/update",
  protect,
  updateTracking
);

// ==========================
// CHECK OUT
// ==========================
router.post(
  "/stop",
  protect,
  stopTracking
);

// ==========================
// CURRENT USER STATUS
// ==========================
router.get(
  "/status",
  protect,
  getMyStatus
);

// ==========================
// ADMIN LIVE USERS
// ==========================
router.get(
  "/live",
  protect,
  adminOnly,
  getAllTracking
);

export default router;