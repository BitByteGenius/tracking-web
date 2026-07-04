import mongoose from "mongoose";

const attendanceSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

   
    attendanceDate: {
     type: String,
     required: true,
},


    // ===========================
    // CHECK IN
    // ===========================

    checkIn: {
      time: {
        type: Date,
      },

      latitude: {
        type: Number,
      },

      longitude: {
        type: Number,
      },

      place: {
        type: String,
        default: "",
      },

      city: {
        type: String,
        default: "",
      },

      state: {
        type: String,
        default: "",
      },

      country: {
        type: String,
        default: "",
      },

      selfie: {
        type: String,
        default: "",
      },
    },

    // ===========================
    // CHECK OUT
    // ===========================

    checkOut: {
      time: {
        type: Date,
      },

      latitude: {
        type: Number,
      },

      longitude: {
        type: Number,
      },

      place: {
        type: String,
        default: "",
      },

      city: {
        type: String,
        default: "",
      },

      state: {
        type: String,
        default: "",
      },

      country: {
        type: String,
        default: "",
      },
    },

    // ===========================
    // LIVE DISTANCE CALCULATION
    // ===========================

    lastLatitude: {
      type: Number,
      default: 0,
    },

    lastLongitude: {
      type: Number,
      default: 0,
    },

    totalDistanceKm: {
      type: Number,
      default: 0,
    },

    // ===========================
    // WORKING TIME
    // ===========================

    workingMinutes: {
      type: Number,
      default: 0,
    },

    // ===========================
    // STATUS
    // ===========================

    status: {
      type: String,
      enum: ["Working", "Present", "Absent"],
      default: "Working",
    },
  },
  {
    timestamps: true,
  }
);

/// One attendance per user per day
attendanceSchema.index(
  {
    user: 1,
    attendanceDate: 1,
  },
  {
    unique: true,
  }
);

// Dashboard queries
attendanceSchema.index({
  status: 1,
});

attendanceSchema.index({
  attendanceDate: 1,
});

export default mongoose.model("Attendance", attendanceSchema);