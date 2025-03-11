const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const wasteRouter = require("./routes/waste");
const adminRouter = require("./routes/admin-recyclecenter");
const userRouter = require("./routes/user");
const carbonRouter = require("./routes/carbon");
const ecolearnRouter = require("./routes/ecolearn");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(authRouter);  
app.use(wasteRouter);
app.use(adminRouter);
app.use(userRouter);
app.use(carbonRouter);
app.use(ecolearnRouter);

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