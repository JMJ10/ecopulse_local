// middleware/admin-auth.js
const jwt = require('jsonwebtoken');
const Admin = require('../models/admin');

const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('admin-token');
    
    if (!token) {
      return res.status(401).json({ msg: 'No authentication token, access denied' });
    }
    
    const verified = jwt.verify(token, process.env.ADMIN_JWT_SECRET || "adminSecretKey");
    if (!verified) {
      return res.status(401).json({ msg: 'Token verification failed, authorization denied' });
    }
    
    // Add this console log to debug
    console.log("Admin ID from token:", verified.id);
    
    const admin = await Admin.findById(verified.id);
    if (!admin) {
      return res.status(401).json({ msg: 'Admin not found, access denied' });
    }
    
    req.admin = admin;
    req.adminId = verified.id;
    next();
  } catch (e) {
    // Log the specific error for debugging
    console.error("Admin auth error:", e.message);
    res.status(401).json({ msg: 'Invalid authentication token' });
  }
};

module.exports = adminAuth;