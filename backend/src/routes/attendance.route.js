import express from "express";
import protect from "../middleware/protect.js";
import upload from "../middleware/upload.middleware.js";

import {
    checkIn,
} from "../controllers/attendance.controller.js";

const router = express.Router();

router.post(
    "/checkin",
    protect,
    upload.single("photo"),
    checkIn
);

export default router;