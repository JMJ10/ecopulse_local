const mongoose = require("mongoose");

const recyclingCenterSchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  phone: {
    type: String,
  },
  acceptedMaterials: {
    type: [String],
    default: [],
  },
  latitude: {
    type: Number,
  },
  longitude: {
    type: Number,
  },
});

const RecyclingCenter = mongoose.model("RecyclingCenter", recyclingCenterSchema);
module.exports = RecyclingCenter;
