const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const WasteLog = require("../models/wastelog");
const RecyclingCenter = require("../models/recyclingcenter");
const CollectionSchedule = require("../models/collectionschedule");

// Log waste
router.post("/api/waste/log", auth, async (req, res) => {
  try {
    const { wasteType, quantity, units, notes } = req.body;
    
    let wasteLog = new WasteLog({
      userId: req.user,
      wasteType,
      quantity,
      units,
      notes,
      logDate: new Date()
    });
    
    wasteLog = await wasteLog.save();
    res.status(201).json(wasteLog);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get waste logs for the current user
router.get("/api/waste/logs", auth, async (req, res) => {
  try {
    const wasteLogs = await WasteLog.find({ userId: req.user });
    res.json(wasteLogs);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get recycling centers (optionally filtered by location)
// This should be added to one of your Express router files (e.g., routes.js)

// Get recycling centers for users (with optional location-based sorting)
router.get('/api/recycling-centers', async (req, res) => {
  try {
    const { lat, lng } = req.query;
    
    // If coordinates are provided, sort centers by distance
    if (lat && lng) {
      // Create a geo query for MongoDB
      const centers = await RecyclingCenter.find({
        location: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [parseFloat(lng), parseFloat(lat)]  // MongoDB uses [longitude, latitude]
            }
          }
        }
      }).limit(50);  // Limit to nearest 50 centers
      
      return res.json(centers);
    } 
    
    // Otherwise, just return all centers
    const centers = await RecyclingCenter.find({}).sort({ createdAt: -1 });
    res.json(centers);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get collection schedules (optionally filtered by location)
router.get("/api/waste/collection-schedules", auth, async (req, res) => {
  try {
    let query = {};
    if (req.query.location) {
      query = { location: { $regex: req.query.location, $options: 'i' } };
    }
    
    const schedules = await CollectionSchedule.find(query)
      .sort({ date: 1 }) // Sort by date ascending
      .limit(20); // Limit to next 20 schedules
    
    res.json(schedules);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;