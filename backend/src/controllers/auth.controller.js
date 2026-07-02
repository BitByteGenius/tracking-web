import User from "../models/user.model.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";

// ─── Helper: Generate JWT for a regular DB user ───────────────────────────
const generateToken = (user) => {
  return jwt.sign(
    {
      userId: user._id,
      role: user.role, // "user" (from MongoDB)
    },
    process.env.JWT_SECRET,
    { expiresIn: "365d" }
  );
};

// ─── Helper: Generate JWT for admin (never stored in DB) ─────────────────
const generateAdminToken = () => {
  return jwt.sign(
    {
      userId: "admin",
      role: "admin",
    },
    process.env.JWT_SECRET,
    { expiresIn: "365d" }
  );
};

// ─── Helper: Safe user object (no password) ───────────────────────────────
const safeUser = (user) => ({
  _id: user._id,
  name: user.name,
  email: user.email,
  phone: user.phone,
  role: user.role,
  profileImage: user.profileImage || "",
});

// ──────────────────────────────────────────────────────────────────────────
// REGISTER
// POST /api/auth/register
// Body: { name, email, phone, password }
// ──────────────────────────────────────────────────────────────────────────
export const authCreateController = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    // Basic validation
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, email, and password are required",
      });
    }

    // Prevent registering with the admin email
    const adminEmail = process.env.ADMIN_EMAIL?.trim().toLowerCase();
    if (email.trim().toLowerCase() === adminEmail) {
      return res.status(403).json({
        success: false,
        message: "This email cannot be used for registration",
      });
    }

    // Check email uniqueness
    const isEmailExist = await User.findOne({ email: email.toLowerCase().trim() });
    if (isEmailExist) {
      return res.status(422).json({
        success: false,
        message: "Email already exists",
      });
    }

    // Check phone uniqueness (only if phone provided)
    if (phone) {
      const isPhoneExist = await User.findOne({ phone });
      if (isPhoneExist) {
        return res.status(422).json({
          success: false,
          message: "Phone number already exists",
        });
      }
    }

    // Hash password with bcryptjs before storing — never store plain text
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      phone: phone || "",
      password: hashedPassword,
    });

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      user: safeUser(user),
      token,
    });
  } catch (error) {
    console.error("REGISTER ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ──────────────────────────────────────────────────────────────────────────
// USER LOGIN
// POST /api/auth/login
// Body: { email, password }
// Validates hashed password with bcrypt. Returns JWT with role: "user".
// ──────────────────────────────────────────────────────────────────────────
export const authLoginController = async (req, res) => {
  try {
    let { email, password } = req.body;

    email = email?.trim().toLowerCase();

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    // Look up user — include password field (it is select:false by default)
    const user = await User.findOne({ email }).select("+password");

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password || "");
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      user: safeUser(user),
      token,
    });
  } catch (error) {
    console.error("LOGIN ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ──────────────────────────────────────────────────────────────────────────
// ADMIN LOGIN
// POST /api/auth/admin-login
// Body: { email, password }
// Validates against ADMIN_EMAIL / ADMIN_PASSWORD in .env only.
// Admin is NEVER stored in MongoDB.
// Returns JWT with { userId: "admin", role: "admin" }.
// ──────────────────────────────────────────────────────────────────────────
export const adminLoginController = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const adminEmail    = process.env.ADMIN_EMAIL?.trim().toLowerCase();
    const adminPassword = process.env.ADMIN_PASSWORD?.trim();

    if (
      email.trim().toLowerCase() !== adminEmail ||
      password.trim() !== adminPassword
    ) {
      return res.status(401).json({
        success: false,
        message: "Invalid admin credentials",
      });
    }

    // Admin is never in MongoDB — synthesise the response object
    const token = generateAdminToken();

    return res.status(200).json({
      success: true,
      user: {
        _id:   "admin",
        name:  "Administrator",
        email: adminEmail,
        phone: "",
        role:  "admin",
        profileImage: "",
      },
      token,
    });
  } catch (error) {
    console.error("ADMIN LOGIN ERROR:", error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
