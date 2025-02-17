const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../models/user");
const authRouter = express.Router();
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");


authRouter.post("/api/signup",async (req,res) => {
    try{
        const { email, password, name, location } = req.body;

        const existingUser = await User.findOne({ email });

        if(existingUser){
            return res
            .status(400)
            .json({ msg: "User with same email already exists!"});
        }

        const hashedPassword = await bcryptjs.hash(password,8);

        let user = new User({
            email: email,
            password: hashedPassword,
            name: name,
            location: location,
        });
        user = await user.save();;
        res.json(user);
    }catch(e){
        res.status(500).json({ error: e.message });
    }
    
 });

 authRouter.post("/api/signin", async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        
        if(!user){
            return res
            .status(400)
            .json({ msg: "User with this email does not exist!" });
        }

        const isMatch = await bcryptjs.compare(password, user.password); 
        if(!isMatch){
            return res.status(400).json({ msg: "Incorrect password" });
        }
        
        const token = jwt.sign({  id: user._id },"passwordKey");
        res.json({ token, ...user._doc });

    } catch (error) {
        res.status(500).json({ error: e.message });
    }
 });

authRouter.post("/tokenIsValid", async (req,res) => {
    try {
        const token = req.header("x-auth-token");
        if(!token){
            return res.json(false);
        }
        const verified = jwt.verify(token,"passwordKey");
        if(!verified){
            return res.json(false);
        }
        const user = await User.findById(verified.id);
        if(!user){
            return res.json(false);
        }
        return res.json(true);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

authRouter.get("/", auth, async (req,res) => {
    const user = await User.findById(req.user);
    res.json({...user._doc, token: req.token});
});

authRouter.get("/api/user", auth, async (req, res) => {
    console.log("GET /api/user endpoint hit, user id:", req.user);
    
    try {
      // Find user by ID (from auth middleware)
      const user = await User.findById(req.user);
      
      if (!user) {
        console.log("User not found for ID:", req.user);
        return res.status(404).json({ msg: "User not found" });
      }
      
      const userResponse = {
        _id: user._id,
        name: user.name,
        email: user.email,
        location: user.location,
      };
      
      console.log("Returning user data for:", user.email);
      res.json(userResponse);
      
    } catch (error) {
      console.error("Error in /api/user endpoint:", error);
      res.status(500).json({ error: error.message });
    }
  });


module.exports = authRouter;
