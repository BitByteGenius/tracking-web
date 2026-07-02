import express from "express";
import protect from "../middleware/protect.js";
import adminOnly from "../middleware/admin.middleware.js";

import {
  startTracking,
  updateTracking,
  stopTracking,
  getMyStatus,
  getAllTracking,
} from "../controllers/tracking.controller.js";

const router = express.Router();

router.post("/start", protect, startTracking);

router.put("/update", protect, updateTracking);

router.post("/stop", protect, stopTracking);

// Current user's own status (used by frontend on app restart)
router.get("/status", protect, getMyStatus);

// Admin Only
router.get(
  "/live",
  protect,
  adminOnly,
  getAllTracking,
);

export default router;