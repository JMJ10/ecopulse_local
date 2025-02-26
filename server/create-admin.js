const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config(); // If you have a .env file

// You'll need to define the same schema here since you're running this outside your server
const adminSchema = mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  role: {
    type: String,
    enum: ['admin', 'super_admin'],
    default: 'admin'
  },
  permissions: {
    manageCenters: {
      type: Boolean,
      default: true
    },
    approveReports: {
      type: Boolean,
      default: true
    }
  },
  createdAt: {
    type: Date,
    default: Date.now,
  }
});

// Hash password before saving
adminSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

const Admin = mongoose.model('Admin', adminSchema);

async function createFirstAdmin() {
  try {
    // Use your production MongoDB connection string here
    const MONGODB_URI = "mongodb+srv://JoelJMJ:Joel2004@ecopulse.9sho1.mongodb.net/?retryWrites=true&w=majority&appName=EcoPulse";
    await mongoose.connect(MONGODB_URI);
    
    console.log('Connected to the deployed MongoDB database');
    
    // Check if any admin exists
    const adminCount = await Admin.countDocuments();
    if (adminCount > 0) {
      console.log('Admin already exists, skipping creation');
      return;
    }
    
    // Create first admin
    const newAdmin = new Admin({
      name: 'SuperAdmin',
      email: 'joelmjoe2004@gmail.com', // Change to your email
      password: 'admin2004', // Will be automatically hashed by the pre-save hook
      role: 'super_admin',
      permissions: {
        manageCenters: true,
        approveReports: true
      }
    });
    
    await newAdmin.save();
    console.log('First admin created successfully!');
  } catch (error) {
    console.error('Error creating admin:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

createFirstAdmin();