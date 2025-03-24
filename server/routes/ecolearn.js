//routes - ecolearn.js
const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const { EcoLearnCategory, EcoLearnTip } = require("../models/ecolearn");

// Get all ecolearn categories and tips
router.get("/api/ecolearn", auth, async (req, res) => {
  try {
    const categories = await EcoLearnCategory.find();
    const tips = await EcoLearnTip.find();

    res.json({
      categories: categories.map((category) => ({
        _id: category._id,
        name: category.name,
        description: category.description,
        iconName: category.iconName,
        articles: category.articles.map((article) => ({
          _id: article._id,
          title: article.title,
          summary: article.summary,
          content: article.content,
          imageUrl: article.imageUrl,
          sourceUrl: article.sourceUrl,
          dateCreated: article.dateCreated.toISOString().split("T")[0],
        })),
      })),
      tips: tips.map((tip) => ({
        _id: tip._id,
        title: tip.title,
        content: tip.content,
        category: tip.category,
        difficulty: tip.difficulty,
      })),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Create a new category
router.post("/api/ecolearn/category", auth, async (req, res) => {
  if (!req.user.isAdmin) {
    return res.status(403).json({ msg: "Not authorized" });
  }

  const { name, description, iconName } = req.body;

  try {
    const newCategory = new EcoLearnCategory({ name, description, iconName });
    const category = await newCategory.save();
    res.json(category);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Add article to category
router.post("/api/ecolearn/category/:id/article", auth, async (req, res) => {
  if (!req.user.isAdmin) {
    return res.status(403).json({ msg: "Not authorized" });
  }

  const { title, summary, content, imageUrl, sourceUrl } = req.body;

  try {
    const category = await EcoLearnCategory.findById(req.params.id);
    if (!category) {
      return res.status(404).json({ msg: "Category not found" });
    }

    const newArticle = { title, summary, content, imageUrl, sourceUrl };
    category.articles.unshift(newArticle);
    await category.save();
    
    res.json(category);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

// Create a new tip
router.post("/api/ecolearn/tip", auth, async (req, res) => {
  if (!req.user.isAdmin) {
    return res.status(403).json({ msg: "Not authorized" });
  }

  const { title, content, category, difficulty } = req.body;

  try {
    const newTip = new EcoLearnTip({
      title,
      content,
      category,
      difficulty: difficulty || 1,
    });

    const tip = await newTip.save();
    res.json(tip);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Server Error");
  }
});

module.exports = router;

