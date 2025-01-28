const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(authRouter);  

const DB = "mongodb+srv://JoelJMJ:Joel2004@ecopulse.9sho1.mongodb.net/?retryWrites=true&w=majority&appName=EcoPulse"

mongoose.connect(DB)
.then(()=>{
    console.log("Connection Successful");
})
.catch((e)=>{
    console.log(e);
})

app.listen(PORT, "0.0.0.0" , ()=>{
    console.log(`Connected at port ${PORT}`);
})