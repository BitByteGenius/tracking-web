

import Tracking from "../models/tracking.model.js";
import Attendance from "../models/attendance.model.js";
import uploadToCloudinary from "../utils/uploadToCloudinary.js";
import { reverseGeocode } from "../services/location.service.js";
import { calculateDistance } from "../utils/distance.js";
import {
  getAttendanceDate,
  getCurrentDateTime,
} from "../utils/date.js";




export const startTracking = async (req, res) => {
  try {
    const userId = req.user.userId;

   const latitude = Number(req.body.latitude);
const longitude = Number(req.body.longitude);
const accuracy = Number(req.body.accuracy || 0);
const speed = Number(req.body.speed || 0);
const heading = Number(req.body.heading || 0);

    // -----------------------------
    // Validation
    // -----------------------------
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Selfie is required.",
      });
    }

    if (
    Number.isNaN(latitude) ||
    Number.isNaN(longitude)
) {
    return res.status(400).json({
        success:false,
        message:"Latitude and Longitude are required."
    });
}

if (accuracy > 50) {
    return res.status(400).json({
        success:false,
        message:"GPS accuracy is too low."
    });
}

    // -----------------------------
    // Attendance Date (India)
    // -----------------------------
    const attendanceDate = getAttendanceDate();

const now = getCurrentDateTime();

    // -----------------------------
    // Already Checked In?
    // -----------------------------
    const alreadyChecked = await Attendance.findOne({
      user: userId,
      attendanceDate,
      status: "Working",
    });

    if (alreadyChecked) {
      return res.status(409).json({
        success: false,
        message: "Already checked in.",
      });
    }

    // -----------------------------
    // Upload Selfie
    // -----------------------------
    const uploaded = await uploadToCloudinary(
      req.file.buffer,
      "attendance"
    );

    // -----------------------------
    // Reverse Geocode
    // -----------------------------
    

    const location = await reverseGeocode(latitude, longitude);

const { place, city, state, country } = location;

    // -----------------------------
    // Create Attendance
    // -----------------------------
    const attendance = await Attendance.create({
      user: userId,

      attendanceDate,

      checkIn: {
        time: now,

        latitude,

        longitude,

        place,

        city,

        state,

        country,

        selfie: uploaded.secure_url,
      },

      lastLatitude: latitude,

      lastLongitude: longitude,

      totalDistanceKm: 0,

      status: "Working",
    });

    // -----------------------------
    // Update Tracking
    // -----------------------------
    const tracking = await Tracking.findOneAndUpdate(
      {
        user: userId,
      },
      {
        user: userId,

        attendance: attendance._id,

        latitude,

        longitude,

        accuracy,

        speed,

        heading,

        place,

        city,

        state,

        country,

        totalDistanceKm: 0,

        status: "Online",

        lastSeen: now,
      },
      {
        upsert: true,
        new: true,
      }
    );

    return res.status(200).json({
      success: true,
      message: "Check In Successful",

      attendance,

      tracking,
    });

  } catch (error) {

    console.log(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};

/////////////////
// Update Tracking (Location Updates)
/////////////////


export const updateTracking = async (req, res) => {
  try {
    const userId = req.user.userId;

   const latitude = Number(req.body.latitude);
const longitude = Number(req.body.longitude);
const accuracy = Number(req.body.accuracy || 0);
const speed = Number(req.body.speed || 0);
const heading = Number(req.body.heading || 0);

   if (
  Number.isNaN(latitude) ||
  Number.isNaN(longitude)
) {
  return res.status(400).json({
    success: false,
    message: "Latitude and longitude are required.",
  });
}

// Ignore inaccurate GPS
if (accuracy > 50) {
  return res.status(200).json({
    success: true,
    message: "Location ignored due to poor GPS accuracy.",
  });
}

    // Find active tracking
    const tracking = await Tracking.findOne({
      user: userId,
      status: "Online",
    });

    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: "Tracking session not found. Please check in first.",
      });
    }

    // Find today's attendance
    const attendance = await Attendance.findOne({
    user: userId,
    attendanceDate: getAttendanceDate(),
    status: "Working",
});

    if (!attendance) {
      return res.status(404).json({
        success: false,
        message: "Attendance record not found.",
      });
    }

    // -------------------------
    // Calculate distance (Haversine)
    // -------------------------
    const distanceKm = calculateDistance(
  attendance.lastLatitude,
  attendance.lastLongitude,
  Number(latitude),
  Number(longitude)
);

// Ignore movement under 10 meters
const finalDistance = distanceKm < 0.01 ? 0 : distanceKm;
    // -------------------------
    // Reverse Geocode
    // -------------------------
    let place = tracking.place;
let city = tracking.city;
let state = tracking.state;
let country = tracking.country;

if (finalDistance >= 0.05) {
    const location = await reverseGeocode(latitude, longitude);

    place = location.place;
    city = location.city;
    state = location.state;
    country = location.country;
}
    // -------------------------
    // Update Attendance
    // -------------------------
    attendance.lastLatitude = latitude;
    attendance.lastLongitude = longitude;
    attendance.totalDistanceKm += finalDistance;

    await attendance.save();

    // -------------------------
    // Update Tracking
    // -------------------------
    tracking.latitude = latitude;
    tracking.longitude = longitude;
    tracking.accuracy = accuracy;
    tracking.speed = speed;
    tracking.heading = heading;

    tracking.place = place;
    tracking.city = city;
    tracking.state = state;
    tracking.country = country;

    tracking.totalDistanceKm = attendance.totalDistanceKm;
    tracking.lastSeen = getCurrentDateTime();

    await tracking.save();

    return res.status(200).json({
      success: true,
      message: "Location updated",
      totalDistanceKm: Number(attendance.totalDistanceKm.toFixed(3)),
      data: tracking,
    });

  } catch (error) {

    console.error(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};


//-------------------
//Stop Tracking (Check Out)
//-------------------


export const stopTracking = async (req, res) => {
  try {
    const userId = req.user.userId;

    const latitude = Number(req.body.latitude);
const longitude = Number(req.body.longitude);

   if (
    Number.isNaN(latitude) ||
    Number.isNaN(longitude)
) {
    return res.status(400).json({
        success:false,
        message:"Latitude and longitude are required.",
    });
} {
      return res.status(400).json({
        success: false,
        message: "Latitude and longitude are required.",
      });
    }

    // Find active tracking
    const attendance = await Attendance.findOne({
    user: userId,
    attendanceDate: getAttendanceDate(),
    status: "Working",
});

    if (!tracking) {
      return res.status(404).json({
        success: false,
        message: "No active tracking session found.",
      });
    }

    // Find attendance
    const attendance = await Attendance.findById(tracking.attendance);

    if (!attendance) {
      return res.status(404).json({
        success: false,
        message: "Attendance record not found.",
      });
    }

    // --------------------------
    // Reverse Geocode
    // --------------------------
    const location = await reverseGeocode(latitude, longitude);

const {
  place,
  city,
  state,
  country,
} = location;
    // --------------------------
    // Save Checkout
    // --------------------------
    attendance.checkOut = {
     time: getCurrentDateTime(),
      latitude,
      longitude,
      place,
      city,
      state,
      country,
    };

    // --------------------------
    // Calculate Working Minutes
    // --------------------------
    const diff =
      attendance.checkOut.time -
      attendance.checkIn.time;

    attendance.workingMinutes = Math.floor(
      diff / 60000
    );

    attendance.status = "Present";

    await attendance.save();

    // --------------------------
    // Stop Tracking
    // --------------------------
    tracking.status = "Offline";
    tracking.lastSeen = getCurrentDateTime();

    await tracking.save();

    // --------------------------
    // Format Hours
    // --------------------------
    const hours = Math.floor(
      attendance.workingMinutes / 60
    );

    const minutes =
      attendance.workingMinutes % 60;

    return res.status(200).json({
      success: true,

      message: "Checked out successfully",

      workingMinutes:
        attendance.workingMinutes,

      workingHours:
        `${hours}h ${minutes}m`,

      totalDistanceKm:
        Number(
          attendance.totalDistanceKm.toFixed(2)
        ),

      attendance,

      tracking,
    });

  } catch (error) {

    console.error(error);

    return res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};