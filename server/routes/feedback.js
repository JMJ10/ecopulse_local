const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const WasteLog = require("../models/wastelog");
const CarbonLog = require("../models/carbonlog");

// Get personalized sustainability recommendations based on user data
router.get("/api/recommendations", auth, async (req, res) => {
  try {
    // Get the user's waste logs
    const wasteLogs = await WasteLog.find({ userId: req.user })
      .sort({ logDate: -1 })
      .limit(20);
    
    // Get the user's carbon logs
    const carbonLogs = await CarbonLog.find({ userId: req.user })
      .sort({ date: -1 })
      .limit(20);
    
    // Analyze waste data
    const wasteRecommendations = generateWasteRecommendations(wasteLogs);
    
    // Analyze carbon emissions data
    const carbonRecommendations = generateCarbonRecommendations(carbonLogs);
    
    // Combine recommendations
    const recommendations = {
      wasteRecommendations,
      carbonRecommendations,
      generalTips: getGeneralSustainabilityTips()
    };
    
    res.json(recommendations);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Generate waste-specific recommendations
function generateWasteRecommendations(wasteLogs) {
  const recommendations = [];
  
  // If no logs, return basic recommendations
  if (!wasteLogs || wasteLogs.length === 0) {
    return [
      {
        type: "info",
        title: "Start tracking your waste",
        description: "Begin logging your waste to receive personalized recommendations."
      }
    ];
  }
  
  // Create a mapping of waste types to total quantities
  const wasteTypeTotals = {};
  wasteLogs.forEach(log => {
    if (!wasteTypeTotals[log.wasteType]) {
      wasteTypeTotals[log.wasteType] = 0;
    }
    wasteTypeTotals[log.wasteType] += log.quantity;
  });
  
  // Identify the most common waste type
  let highestWasteType = null;
  let highestQuantity = 0;
  
  for (const [type, quantity] of Object.entries(wasteTypeTotals)) {
    if (quantity > highestQuantity) {
      highestQuantity = quantity;
      highestWasteType = type;
    }
  }
  
  // Add waste-specific recommendations
  if (highestWasteType === "Plastic") {
    recommendations.push({
      type: "warning",
      title: "High plastic waste detected",
      description: "Consider using reusable containers and bags to reduce plastic waste."
    });
  } else if (highestWasteType === "Paper") {
    recommendations.push({
      type: "warning",
      title: "High paper waste detected",
      description: "Try going digital with bills and documents to reduce paper consumption."
    });
  } else if (highestWasteType === "Organic") {
    recommendations.push({
      type: "suggestion",
      title: "Consider composting",
      description: "Your organic waste could be turned into valuable compost for gardens."
    });
  }
  
  // Check for overall reduction trends
  if (wasteLogs.length >= 5) {
    const recentLogs = wasteLogs.slice(0, 5);
    const olderLogs = wasteLogs.slice(5, 10);
    
    const recentTotal = recentLogs.reduce((sum, log) => sum + log.quantity, 0);
    const olderTotal = olderLogs.reduce((sum, log) => sum + log.quantity, 0);
    
    if (recentTotal < olderTotal) {
      recommendations.push({
        type: "success",
        title: "Waste reduction progress!",
        description: "You've reduced your waste compared to previous logs. Keep it up!"
      });
    }
  }
  
  return recommendations;
}

// Generate carbon emissions recommendations
function generateCarbonRecommendations(carbonLogs) {
  const recommendations = [];
  
  // If no logs, return basic recommendations
  if (!carbonLogs || carbonLogs.length === 0) {
    return [
      {
        type: "info",
        title: "Start tracking your emissions",
        description: "Begin logging your travel to receive personalized carbon recommendations."
      }
    ];
  }
  
  // Group by transport mode
  const transportModeTotals = {};
  carbonLogs.forEach(log => {
    if (!transportModeTotals[log.transportMode]) {
      transportModeTotals[log.transportMode] = {
        emissions: 0,
        distance: 0,
        count: 0
      };
    }
    transportModeTotals[log.transportMode].emissions += log.emissions;
    transportModeTotals[log.transportMode].distance += log.distance;
    transportModeTotals[log.transportMode].count += 1;
  });
  
  // Check if car is the most used transport
  if (transportModeTotals['Car'] && 
      transportModeTotals['Car'].count > 
      (transportModeTotals['Bus']?.count || 0) + 
      (transportModeTotals['Train']?.count || 0) + 
      (transportModeTotals['Bike']?.count || 0)) {
    
    recommendations.push({
      type: "warning",
      title: "High car usage detected",
      description: "Consider carpooling, public transport, or cycling for shorter trips to reduce emissions."
    });
    
    // Check average trip distance
    const avgCarDistance = transportModeTotals['Car'].distance / transportModeTotals['Car'].count;
    if (avgCarDistance < 3) { // Short trips under 3 miles
      recommendations.push({
        type: "suggestion",
        title: "Short car trips",
        description: "Your car trips are quite short. Consider walking or cycling for these distances."
      });
    }
  }
  
  // Check for bicycle usage
  if (!transportModeTotals['Bike'] || transportModeTotals['Bike'].count === 0) {
    recommendations.push({
      type: "suggestion",
      title: "Try cycling",
      description: "You haven't logged any bicycle trips. Cycling is a zero-emission way to travel short distances."
    });
  }
  
  // Check for overall emission reduction trends
  if (carbonLogs.length >= 5) {
    const recentLogs = carbonLogs.slice(0, 5);
    const olderLogs = carbonLogs.slice(5, 10);
    
    const recentEmissions = recentLogs.reduce((sum, log) => sum + log.emissions, 0);
    const olderEmissions = olderLogs.reduce((sum, log) => sum + log.emissions, 0);
    
    if (recentEmissions < olderEmissions) {
      recommendations.push({
        type: "success",
        title: "Emissions reduction progress!",
        description: "You've reduced your carbon emissions compared to previous trips. Great work!"
      });
    }
  }
  
  return recommendations;
}

// General sustainability tips
function getGeneralSustainabilityTips() {
  const tips = [
    {
      type: "tip",
      title: "Energy conservation",
      description: "Turn off lights and unplug devices when not in use to reduce electricity consumption."
    },
    {
      type: "tip",
      title: "Water conservation",
      description: "Take shorter showers and fix leaky faucets to conserve water."
    },
    {
      type: "tip",
      title: "Reusable items",
      description: "Invest in reusable water bottles, shopping bags, and food containers."
    },
    {
      type: "tip",
      title: "Buy local",
      description: "Purchase locally grown food to reduce transportation emissions."
    },
    {
      type: "tip",
      title: "Plant-based meals",
      description: "Try incorporating more plant-based meals into your diet to reduce your carbon footprint."
    }
  ];
  
  // Return 2 random tips
  return tips.sort(() => 0.5 - Math.random()).slice(0, 2);
}

module.exports = router;