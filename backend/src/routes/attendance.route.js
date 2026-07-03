import express from "express";
import protect from "../middleware/protect.js";

import {
  getTodayAttendance,
  getAttendanceHistory,
  getAllAttendance,
} from "../controllers/attendance.controller.js";

const router = express.Router();

router.get("/today", protect, getTodayAttendance);
router.get("/history", protect, getAttendanceHistory);

// Admin
router.get("/all", protect, getAllAttendance);

export default router;