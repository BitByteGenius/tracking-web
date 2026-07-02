import Tracking from "../models/tracking.model.js";


// =======================
// CHECK IN  (Start Tracking)
// POST /api/tracking/start
// =======================

export const startTracking = async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log(`[startTracking] request received — userId: ${userId}`);

    const {
      latitude,
      longitude,
      accuracy,
      speed,
      heading,
      place,
      city,
      state,
      country,
    } = req.body;

    // ── Duplicate check-in guard ──────────────────────────────────────────
    // If this user already has an "Online" record, reject the second check-in.
    const existing = await Tracking.findOne({ user: userId, status: "Online" });
    console.log(`[startTracking] existing Online record: ${existing ? existing._id : "none"}`);
    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Already checked in. Please check out first.",
      });
    }

    // Upsert the tracking document (create if first time, update if returning)
    const tracking = await Tracking.findOneAndUpdate(
      { user: userId },
      {
        user: userId,
        latitude,
        longitude,
        accuracy,
        speed,
        heading,
        place,
        city,
        state,
        country,
        status: "Online",
        lastSeen: new Date(),
      },
      {
        upsert: true,
        new: true,
      }
    );

    return res.status(200).json({
      success: true,
      message: "Checked in successfully",
      data: tracking,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =======================
// UPDATE LOCATION
// PUT /api/tracking/update
// =======================

export const updateTracking = async (req, res) => {
  try {
    const userId = req.user.userId;

    const update = {
      ...req.body,
      status: "Online",
      lastSeen: new Date(),
    };

    const tracking = await Tracking.findOneAndUpdate(
      {
        user: userId,
      },
      update,
      {
        new: true,
      }
    );

    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: "Tracking session not found. Please check in first.",
      });
    }

    return res.json({
      success: true,
      message: "Location updated",
      data: tracking,
    });

  } catch (error) {

    return res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};


// =======================
// CHECK OUT  (Stop Tracking)
// POST /api/tracking/stop
// =======================

export const stopTracking = async (req, res) => {
  try {

    const userId = req.user.userId;
    console.log(`[stopTracking] request received — userId: ${userId}`);

    // Only update a document that is currently Online.
    // If the user is already Offline (or has no record), return 404
    // so the frontend knows the session did not exist / was already closed.
    const tracking = await Tracking.findOneAndUpdate(
      {
        user: userId,
        status: "Online",   // ← guard: only match an active session
      },
      {
        status: "Offline",
        lastSeen: new Date(),
      },
      {
        new: true,
      }
    );
    console.log(`[stopTracking] findOneAndUpdate result: ${tracking ? `found — new status: ${tracking.status}` : "null (no Online record matched)"}`);

    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: "No active tracking session found.",
      });
    }

    return res.json({
      success: true,
      message: "Checked out successfully",
      data: tracking,
    });

  } catch (error) {

    return res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};


// =======================
// GET CURRENT USER STATUS
// GET /api/tracking/status
// Returns the authenticated user's own tracking record (Online or Offline).
// The frontend calls this on app restart to sync _isTracking with reality.
// =======================

export const getMyStatus = async (req, res) => {
  try {
    const userId = req.user.userId;

    const tracking = await Tracking.findOne({ user: userId })
      .populate("user", "name email phone profileImage");

    if (!tracking) {
      return res.json({
        success: true,
        status: "Offline",
        data: null,
      });
    }

    return res.json({
      success: true,
      status: tracking.status,
      data: tracking,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};


// =======================
// ADMIN: GET LIVE USERS
// GET /api/tracking/live
// Returns only Online users, populated with user name/email.
// =======================

export const getAllTracking = async (req, res) => {
  try {
    const tracking = await Tracking.find({
      status: "Online",
    })
      .populate("user", "name email phone profileImage")
      .sort({ updatedAt: -1 });

    return res.json({
      success: true,
      total: tracking.length,
      data: tracking,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};