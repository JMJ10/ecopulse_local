const jwt = require('jsonwebtoken');
const Admin = require('../models/admin');

const adminAuth = async (req, res, next) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) return res.status(401).json({ msg: 'No auth token' });

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    const admin = await Admin.findById(verified.id);
    
    if (!admin) return res.status(401).json({ msg: 'Admin not found' });
    
    req.admin = admin;
    req.token = token;
    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = adminAuth;