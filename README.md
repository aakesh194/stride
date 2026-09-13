# Stride

An iOS app for tracking mobility and health insights via HealthKit.

## Setup

1. Copy `Stride/Resources/Config.xcconfig.example` to `Stride/Resources/Config.xcconfig`
2. Fill in your `API_KEY` value
3. Open `Stride.xcodeproj` in Xcode and run

## Structure

```
Stride/
├── Views/        SwiftUI views
├── ViewModels/   View models
├── Services/     HealthKit and insight services
├── Models/       Data models
├── Resources/    Assets and config
└── StrideApp.swift  App entry point
```
