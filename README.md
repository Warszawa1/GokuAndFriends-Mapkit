# GokuAndFriends

A Dragon Ball-themed iOS application demonstrating core iOS development concepts with UIKit.

## Project Overview

This project showcases my learning journey in iOS development, implementing various patterns and technologies including:

- MVVM Architecture
- Secure data management
- Core Data integration
- Unit testing
- UIKit programmatic interfaces

## Features

- User authentication flow
- Character listing and details
- Secure data storage using KeychainSwift
- Persistent storage with Core Data

## Project Structure

The project follows a clean architecture approach with clear separation of concerns:

### Presentation Layer
- **Heroes**: UI components for displaying character information
  - HeroesController: Main listing view controller
  - HeroCell: Custom cell for character display
  - HeroesViewModel: View model for character data
- **Splash & Login**: Onboarding experience

### Data Layer
- **CoreData**: Database models and persistence
- **SecureDataProvider**: Secure storage implementation using KeychainSwift

### Domain Layer
- **Model**: Core business models like Hero
- **UseCase**: Business logic implementations

### Networking
- API communication handling
- SceneDelegate for app lifecycle management

## Testing

The project includes:
- Unit tests for data providers
- ViewModel tests
- Use case tests
- Mock implementations for testing

## What I Learned

Through this project, I've gained experience with:

1. **Secure Data Management**: Implementing KeychainSwift for sensitive information storage
2. **MVVM Architecture**: Properly separating concerns between view, model, and business logic
3. **Unit Testing**: Creating comprehensive tests for all layers of the application
4. **XIB-Based UI Development**: Creating interfaces using XIB files for better separation of UI components
5. **Core Data**: Setting up and managing persistent storage
6. **API Integration**: Fetching and processing remote data

## Getting Started

1. Clone the repository
2. Open GokuAndFriends.xcodeproj in Xcode
3. Build and run the project on your simulator or device

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Dependencies

- KeychainSwift (24.0.0)
