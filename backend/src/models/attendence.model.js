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
      index: true,
    },

    checkIn: {
      time: Date,

      latitude: Number,

      longitude: Number,

      address: {
        type: String,
        default: "",
      },

      selfie: {
        type: String,
        default: "",
      },
    },

    checkOut: {
      time: Date,

      latitude: Number,

      longitude: Number,

      address: {
        type: String,
        default: "",
      },
    },

    workingMinutes: {
      type: Number,
      default: 0,
    },

    status: {
      type: String,
      enum: [
        "Working",
        "Present",
        "Absent",
      ],
      default: "Working",
    },
  },
  {
    timestamps: true,
  }
);

// Prevent duplicate attendance for the same user on the same day
attendanceSchema.index(
  {
    user: 1,
    attendanceDate: 1,
  },
  {
    unique: true,
  }
);

export default mongoose.model("Attendance", attendanceSchema);