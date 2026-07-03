import Attendance from "../models/attendance.model.js";
import {
  getAttendanceDate,
  getCurrentDateTime,
} from "../utils/date.js";


// Helper to get today's date in India
const attendanceDate = getAttendanceDate();

const now = getCurrentDateTime();

// ===============================
// GET TODAY ATTENDANCE
// GET /api/attendance/today
// ===============================
export const getTodayAttendance = async (req, res) => {
  try {
    const userId = req.user.userId;

    const attendance = await Attendance.findOne({
      user: userId,
      attendanceDate: getAttendanceDate(),
    }).populate("user", "name email phone profileImage");

    if (!attendance) {
      return res.status(200).json({
        success: true,
        checkedIn: false,
        data: null,
      });
    }

    return res.status(200).json({
      success: true,
      checkedIn: attendance.status === "Working",
      data: attendance,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
// GET MY ATTENDANCE HISTORY
// GET /api/attendance/history
// ===============================
export const getAttendanceHistory = async (req, res) => {
  try {
    const userId = req.user.userId;

    const attendance = await Attendance.find({
      user: userId,
    }).sort({
      attendanceDate: -1,
    });

    return res.status(200).json({
      success: true,
      total: attendance.length,
      data: attendance,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ===============================
// ADMIN ATTENDANCE
// GET /api/attendance/all
// ===============================
export const getAllAttendance = async (req, res) => {
  try {
    const attendance = await Attendance.find()
      .populate("user", "name email phone profileImage")
      .sort({
        attendanceDate: -1,
      });

    return res.status(200).json({
      success: true,
      total: attendance.length,
      data: attendance,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};