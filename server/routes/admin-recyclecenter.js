const express = require('express');
const router = express.Router();
const Admin = require('../models/admin');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const RecyclingCenter = require('../models/recyclingcenter');
const adminAuth = require('../middleware/adminauth');

// Admin Sign In
router.post('/api/admin/signin', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate inputs
    if (!email || !password) {
      return res.status(400).json({ msg: 'Please enter all fields' });
    }

    // Check if admin exists
    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign(
      { id: admin._id, role: admin.role },
      "adminSecretKey", // Use a hardcoded secret like user auth
      { expiresIn: '24h' }
    );
    res.json({
      token,
      admin: {
        id: admin._id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        permissions: admin.permissions
      }
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Validate Admin Token
router.post('/api/admin/tokenIsValid', async (req, res) => {
  try {
    const token = req.header('x-auth-token');
    if (!token) return res.json(false);

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    if (!verified) return res.json(false);

    const admin = await Admin.findById(verified.id);
    if (!admin) return res.json(false);

    return res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get Admin Data
router.get('/admin', adminAuth, async (req, res) => {
  try {
    const admin = await Admin.findById(req.adminId);
    if (!admin) {
      return res.status(404).json({ msg: 'Admin not found' });
    }
    
    res.json({
      id: admin._id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      permissions: admin.permissions
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Create New Admin (Only for super_admin)
router.post('/api/admin/create', adminAuth, async (req, res) => {
  try {
    // Check if requester is a super_admin
    if (req.admin.role !== 'super_admin') {
      return res.status(403).json({ msg: 'Permission denied. Only super admins can create new admins.' });
    }

    const { name, email, password, role, permissions } = req.body;

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ msg: 'Admin with this email already exists' });
    }

    // Create new admin
    const newAdmin = new Admin({
      name,
      email,
      password,
      role: role || 'admin',
      permissions: permissions || {
        manageCenters: true,
        approveReports: true
      }
    });

    await newAdmin.save();
    res.status(201).json({ msg: 'Admin created successfully' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Add a new recycling center (Admin only)
router.post('/api/admin/recycling-centers', adminAuth, async (req, res) => {
  try {
    if (!req.admin.permissions.manageCenters) {
      return res.status(403).json({ msg: 'Permission denied' });
    }

    const { name, address, phone, acceptedMaterials, location, operatingHours, website } = req.body;

    const center = new RecyclingCenter({
      name,
      address,
      phone,
      acceptedMaterials,
      location,
      operatingHours,
      website,
      addedBy: req.adminId
    });

    await center.save();
    res.status(201).json(center);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get all recycling centers (Admin view)
router.get('/api/admin/recycling-centers', adminAuth, async (req, res) => {
  try {
    const centers = await RecyclingCenter.find({})
      .sort({ createdAt: -1 });
    res.json(centers);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Update a recycling center
router.put('/api/admin/recycling-centers/:id', adminAuth, async (req, res) => {
  try {
    if (!req.admin.permissions.manageCenters) {
      return res.status(403).json({ msg: 'Permission denied' });
    }

    const { id } = req.params;
    const updates = req.body;
    
    const center = await RecyclingCenter.findByIdAndUpdate(
      id,
      updates,
      { new: true }
    );

    if (!center) {
      return res.status(404).json({ msg: 'Recycling center not found' });
    }

    res.json(center);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Delete a recycling center
router.delete('/api/admin/recycling-centers/:id', adminAuth, async (req, res) => {
  try {
    if (!req.admin.permissions.manageCenters) {
      return res.status(403).json({ msg: 'Permission denied' });
    }

    const { id } = req.params;
    const center = await RecyclingCenter.findByIdAndDelete(id);
    
    if (!center) {
      return res.status(404).json({ msg: 'Recycling center not found' });
    }

    res.json({ msg: 'Recycling center deleted successfully' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;