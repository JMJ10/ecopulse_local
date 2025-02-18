
// recyclingcenter.js
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
  location: {
    type: {
      type: String,
      enum: ['Point'],
      required: true
    },
    coordinates: {
      type: [Number],  // [longitude, latitude]
      required: true
    }
  },
  operatingHours: {
    type: String,
  },
  website: {
    type: String,
  }
});

// Create a 2dsphere index for geospatial queries
recyclingCenterSchema.index({ location: '2dsphere' });

// Add a method to get centers within a radius
recyclingCenterSchema.statics.findNearby = function(coordinates, maxDistance = 10000) {
  return this.find({
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: coordinates // [longitude, latitude]
        },
        $maxDistance: maxDistance // Distance in meters
      }
    }
  });
};

const RecyclingCenter = mongoose.model("RecyclingCenter", recyclingCenterSchema);
module.exports = RecyclingCenter;
