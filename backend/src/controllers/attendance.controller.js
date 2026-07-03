import Attendance from "../models/attendance.model.js";
import uploadToCloudinary from "../utils/uploadToCloudinary.js";

export const checkIn = async (req, res) => {
    try {

        const userId = req.user.userId;

        const {
            latitude,
            longitude,
            address,
        } = req.body;

        // Validate Photo
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "Selfie is required.",
            });
        }

        // Validate GPS
        if (!latitude || !longitude) {
            return res.status(400).json({
                success: false,
                message: "Location is required.",
            });
        }

        // Today's Date
        const attendanceDate = new Date()
            .toISOString()
            .split("T")[0];

        // Already Checked In?
        const alreadyChecked = await Attendance.findOne({
            user: userId,
            attendanceDate,
        });

        if (alreadyChecked) {
            return res.status(400).json({
                success: false,
                message: "You have already checked in today.",
            });
        }

        // Upload Selfie
        const uploadedImage = await uploadToCloudinary(
            req.file.buffer,
            "attendance"
        );

        // Save Attendance
        const attendance = await Attendance.create({

            user: userId,

            attendanceDate,

            checkIn: {

                time: new Date(),

                latitude,

                longitude,

                address,

                selfie: uploadedImage.secure_url,
            },

            status: "Working",

        });

        return res.status(201).json({

            success: true,

            message: "Check In Successful",

            data: attendance,

        });

    } catch (error) {

        console.log(error);

        return res.status(500).json({

            success: false,

            message: error.message,

        });

    }
};