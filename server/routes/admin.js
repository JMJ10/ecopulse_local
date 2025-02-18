const express = require('express');
const router = express.Router();
const Admin = require('../models/admin');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const adminAuth = require('../middleware/admin-auth');

// Admin signup (should be restricted in production)
router.post('/admin/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ msg: 'Admin with this email already exists' });
    }

    const admin = new Admin({
      email,
      password,
      name,
    });

    await admin.save();
    res.status(201).json({ msg: 'Admin account created successfully' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Admin login
router.post('/admin/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ msg: 'Admin with this email does not exist' });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Incorrect password' });
    }

    const token = jwt.sign({ id: admin._id }, process.env.JWT_SECRET);
    res.json({
      token,
      admin: {
        id: admin._id,
        name: admin.name,
        email: admin.email,
        role: admin.role
      }
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

