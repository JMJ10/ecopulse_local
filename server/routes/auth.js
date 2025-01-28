const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../models/user");
const authRouter = express.Router();

authRouter.post("/api/signup",async (req,res) => {
    try{
        const { email, password } = req.body;

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

module.exports = authRouter;
