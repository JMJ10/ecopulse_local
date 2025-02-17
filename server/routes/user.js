const express = require("express");
const router = express.Router();
const User = require("../models/user");

// Update user profile
router.put("/user/:id", async (req, res) => {
    try {
        const { name, email, location } = req.body;
        const updatedUser = await User.findByIdAndUpdate(
            req.params.id,
            { name, email, location },
            { new: true }
        );
        if (!updatedUser) {
            return res.status(404).json({ error: "User not found" });
        }
        res.json(updatedUser);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
