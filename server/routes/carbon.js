const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const CarbonLog = require("../models/carbonlog");

// Log carbon emissions
router.post("/api/carbon/log", auth, async (req, res) => {
  try {
    const { transportMode, distance, emissions, notes } = req.body;
    
    let carbonLog = new CarbonLog({
      userId: req.user,
      transportMode,
      distance,
      emissions,
      notes,
      date: new Date()
    });
    
    carbonLog = await carbonLog.save();
    res.status(201).json(carbonLog);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get carbon logs for the current user
router.get("/api/carbon/logs", auth, async (req, res) => {
  try {
    const carbonLogs = await CarbonLog.find({ userId: req.user });
    res.json(carbonLogs);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Get aggregated emissions by transport mode
router.get("/api/carbon/by-mode", auth, async (req, res) => {
  try {
    const aggregatedData = await CarbonLog.aggregate([
      { $match: { userId: req.user } },
      { 
        $group: {
          _id: "$transportMode",
          totalEmissions: { $sum: "$emissions" },
          totalDistance: { $sum: "$distance" }
        }
      }
    ]);
    res.json(aggregatedData);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;