const mongoose = require("mongoose");

const collectionScheduleSchema = mongoose.Schema({
  location: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  wasteType: {
    type: String,
    required: true,
  },
  notes: {
    type: String,
  },
});

const CollectionSchedule = mongoose.model("CollectionSchedule", collectionScheduleSchema);
module.exports = CollectionSchedule;