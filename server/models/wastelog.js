const mongoose = require("mongoose");

const wasteLogSchema = mongoose.Schema({
  userId: {
    type: String,
    required: true,
  },
  wasteType: {
    type: String,
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
  },
  units: {
    type: String,
    required: true,
    default: 'kg',
  },
  notes: {
    type: String,
  },
  logDate: {
    type: Date,
    required: true,
  }
});

const WasteLog = mongoose.model("WasteLog", wasteLogSchema);
module.exports = WasteLog;