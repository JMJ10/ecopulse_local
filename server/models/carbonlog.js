const mongoose = require("mongoose");

const carbonLogSchema = mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  transportMode: {
    type: String,
    required: true,
  },
  distance: {
    type: Number,
    required: true,
  },
  emissions: {
    type: Number,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  notes: {
    type: String,
  }
});

const CarbonLog = mongoose.model("CarbonLog", carbonLogSchema);
module.exports = CarbonLog;