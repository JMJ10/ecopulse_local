// models/ecolearn.js
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Article Schema
const EcoLearnArticleSchema = new Schema({
  title: {
    type: String,
    required: true
  },
  summary: {
    type: String,
    required: true
  },
  content: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String
  },
  sourceUrl: {
    type: String
  },
  dateCreated: {
    type: Date,
    default: Date.now
  }
});

// Category Schema
const EcoLearnCategorySchema = new Schema({
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  iconName: {
    type: String,
    required: true
  },
  articles: [EcoLearnArticleSchema]
});

// Tips Schema
const EcoLearnTipSchema = new Schema({
  title: {
    type: String,
    required: true
  },
  content: {
    type: String,
    required: true
  },
  category: {
    type: String
  },
  difficulty: {
    type: Number,
    min: 1,
    max: 5,
    default: 1
  },
  dateCreated: {
    type: Date,
    default: Date.now
  }
});

module.exports = {
  EcoLearnCategory: mongoose.model('EcoLearnCategory', EcoLearnCategorySchema),
  EcoLearnTip: mongoose.model('EcoLearnTip', EcoLearnTipSchema)
};
