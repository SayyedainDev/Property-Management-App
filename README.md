🚀 Features Overview
👤 User Features
Feature	Description
🔐 Authentication	Sign up, login, and logout via Firebase Auth
🏠 Browse Properties	View all available properties in a scrollable list
🔍 Search	Search properties by title or city
❤️ Favorites	Save properties for later
📅 Book Property	Choose check-in & check-out dates and confirm booking
📋 My Bookings	Track booking statuses
❌ Cancel Booking	Cancel pending bookings
👤 Profile	Manage user profile information
🏢 Owner Features
Feature	Description
📊 Dashboard	Overview of total properties & bookings
➕ Add Property	Create new listings with multiple images
🖼️ Image Upload	Upload images to Supabase storage
📝 Manage Properties	Edit or remove existing listings
📅 View Bookings	See bookings for owned properties
✅ Update Status	Confirm or cancel booking requests
🌐 Offline Support
Feature	Description
📶 Connectivity Detection	Automatic monitoring of internet connection
💾 Local Caching	Properties cached using Hive
🔄 Offline Mode	Browse cached data without internet
⚠️ Offline Banner	Clear banner indicating offline status



┌─────────────────────────────────────────────────────────────────┐
│                        NESTFINDER APP                           │
├─────────────────────────────────────────────────────────────────┤

PRESENTATION LAYER
  • Screens
  • Pages
  • Widgets (PropertyCard, CustomButton, InputField)

┌──────────────────────────┐      ┌──────────────────────────────┐
│        PRESENTATION      │◄────►│           WIDGETS            │
└──────────────────────────┘      └──────────────────────────────┘

STATE MANAGEMENT
  • LoginProvider
  • OwnerProvider
  • UserProvider
  • BookingProvider

┌──────────────────────────┐
│      STATE MANAGEMENT    │
└──────────────────────────┘

MODELS
  • UserModel
  • OwnerModel
  • BookingModel

SERVICES
  • Firebase Auth & Firestore
  • Supabase (Images)
  • Hive (Local Cache)

