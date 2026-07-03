import Attendance from "../models/attendance.model.js";
import Tracking from "../models/tracking.model.js";

import uploadToCloudinary from "../utils/uploadToCloudinary.js";

import { reverseGeocode } from "./location.service.js";

import { calculateDistance } from "../utils/distance.js";

import {
  getAttendanceDate,
  getCurrentDateTime,
} from "../utils/date.js";

class AttendanceService {

  // ===========================
  // CHECK IN
  // ===========================

  async checkIn({
    userId,
    file,
    latitude,
    longitude,
    accuracy = 0,
    speed = 0,
    heading = 0,
  }) {

    // We will implement this next

  }

  // ===========================
  // UPDATE LOCATION
  // ===========================

  async updateLocation({
    userId,
    latitude,
    longitude,
    accuracy = 0,
    speed = 0,
    heading = 0,
  }) {

    // We will implement this next

  }

  // ===========================
  // CHECK OUT
  // ===========================

  async checkOut({
    userId,
    latitude,
    longitude,
  }) {

    // We will implement this next

  }

}

export default new AttendanceService();