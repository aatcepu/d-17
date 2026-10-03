# NutriLenz App Structure

## Overview
NutriLenz is an iOS app that uses machine learning to identify food items from photos and provide nutritional information. The app works completely offline and prioritizes user privacy.

## Directory Structure
```
NutriLenz/
├── NutriLenzApp.swift                 // App entry point
├── Assets.xcassets                    // Images, icons, colors
├── Preview Content/
│
├── Models/
│   ├── FoodItem.swift                 // Each food item schema
│   ├── NutritionFacts.swift           // Calorie/macros struct
│   ├── Meal.swift                     // Saved meal model
│   ├── PortionEstimate.swift          // Portion estimation model
│   ├── DetectionResult.swift          // ML + Vision result model
│   └── AppError.swift                 // Error handling model
│
├── ViewModels/
│   ├── CameraViewModel.swift          // Handles camera frames
│   ├── DetectionViewModel.swift       // Vision + CoreML pipeline
│   ├── NutritionViewModel.swift       // Calorie & macro calculator
│   ├── MealHistoryViewModel.swift     // CoreData history logic
│   └── DashboardViewModel.swift       // Daily summary logic
│
├── Views/
│   ├── OnboardingView.swift
│   ├── CameraView.swift               // Live camera preview
│   ├── DetectionResultView.swift      // Results after scan
│   ├── AdjustPortionView.swift        // User edits serving size
│   ├── DailySummaryView.swift         // Swift Charts dashboard
│   ├── MealHistoryView.swift
│   ├── MealDetailView.swift
│   └── SettingsView.swift
│
├── Services/
│   ├── CameraService.swift            // AVCaptureSession manager
│   ├── VisionService.swift            // VNCoreMLRequest manager
│   ├── PortionEstimator.swift         // Plate detection + math
│   ├── MealScoreEngine.swift          // Offline scoring logic
│   ├── ColorAnalysisService.swift     // Detect cooked/raw, colors
│   └── LocalNotificationService.swift // Optional hydration reminders
│
├── CoreML/
│   ├── FoodClassifier.mlmodel         // Food101 or custom model
│   └── FoodClassifierMetadata.json    // Labels, mapping, etc.
│
├── Database/
│   ├── CoreDataModel.xcdatamodeld     // Meal + Food entities
│   ├── NutritionDatabase.json         // Offline calorie data
│   └── NutritionDBLoader.swift        // Loads JSON → Models
│
├── Utils/
│   ├── Extensions/
│   │   ├── UIImage+Resize.swift
│   │   ├── UIImage+PixelBuffer.swift
│   │   ├── VNObservation+Helpers.swift
│   │   ├── Double+Format.swift
│   │   └── Color+Category.swift
│   ├── HoughTransform.swift           // Plate detection math
│   ├── HistogramAnalyzer.swift        // Cooked/raw detection
│   └── Constants.swift
│
└── Resources/
    ├── OnboardingImages/
    ├── SampleMeals/
    └── AppIcon.appiconset/
```

## Key Features Implemented

1. **Onboarding Screen** - Explains the app's offline, privacy-focused nature
2. **Camera/Scan Screen** - Main screen for taking food photos with instant detection
3. **Food Analysis Screen** - Shows recognized foods, portion estimates, calories, macros, meal score
4. **Edit/Adjust Screen** - Allows users to adjust portions and correct detections
5. **Daily Summary Screen** - Shows total calories, macro breakdown, meal timeline, hydration index
6. **Meal History Screen** - List of previous meals with thumbnails stored offline
7. **Settings Screen** - Theme, database update, export data, privacy info
8. **Profile/Stats Screen** - Long-term analytics and trends

## Technical Implementation

- SwiftUI for UI
- AVFoundation for camera functionality
- Vision and CoreML for food detection
- Core Data for offline meal storage
- Swift Charts for data visualization
- Custom algorithms for portion estimation
- Comprehensive error handling

## Privacy & Offline Functionality

- All processing occurs on-device
- No images or personal data are uploaded
- Machine learning models run locally
- Data stored locally with Core Data