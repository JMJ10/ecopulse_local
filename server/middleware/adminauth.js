// middleware/admin-auth.js
const jwt = require('jsonwebtoken');
const Admin = require('../models/admin');

const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) {
      return res.status(401).json({ msg: 'No auth token, access denied' });
    }

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    if (!verified) {
      return res.status(401).json({ msg: 'Token verification failed, access denied' });
    }

    // Get admin details including permissions
    const admin = await Admin.findById(verified.id);
    if (!admin) {
      return res.status(401).json({ msg: 'Admin not found' });
    }

    req.adminId = verified.id;
    req.admin = {
      role: admin.role,
      permissions: admin.permissions
    };
    
    next();
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};

module.exports = adminAuth;