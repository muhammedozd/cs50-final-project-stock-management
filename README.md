# CS50 Final Project – Stock Management Application

## Video Demo
https://www.youtube.com/watch?v=uzCo_6zFH0w

## Description

This project is a **Stock Management Application** developed as my **CS50x Final Project**. The goal of this application is to help small businesses, individual sellers, or personal users track their products, stock quantities, and minimum stock levels in a simple and efficient way. Many small-scale users still rely on notebooks or spreadsheets to manage inventory, which can easily lead to mistakes, forgotten updates, or data loss. This project aims to solve that problem by providing a lightweight, offline-first digital solution.

The application allows users to add products, update stock quantities, set minimum stock thresholds, and monitor inventory levels through a clean and intuitive interface. When stock levels fall close to or below the defined minimum, users can immediately see that action is required. The app is designed to be easy to use even for users without technical knowledge.

This project was built using **Flutter** for the frontend and **SQLite** for local data storage. All application data is stored locally on the device, meaning no external servers or cloud services are required. This design choice ensures privacy, offline usability, and simplicity.

## Features

The Stock Management Application includes the following core features:

- Add new products with a name, stock quantity, and minimum stock value  
- Edit existing products and update stock levels  
- Delete products that are no longer needed  
- Search products by name for quick access  
- Store all data locally using SQLite  
- Clean and simple user interface optimized for mobile devices  

These features cover the most essential needs of basic inventory management while keeping the application lightweight and easy to maintain.

## Technologies Used

This project uses the following technologies and tools:

- **Flutter**: Used to build a cross-platform mobile application with a responsive UI  
- **Dart**: Programming language used with Flutter  
- **SQLite**: Local database for storing product and stock data  
- **VS Code / CS50 Codespace**: Development environment  
- **Git & GitHub**: Version control and project hosting  

Flutter was chosen because it allows fast UI development and produces consistent results across platforms. SQLite was selected because it is lightweight, reliable, and perfect for offline data storage.

## File Structure

The project is organized into several key files and folders:

- `lib/`  
  - Contains the main Dart source code of the application  
  - Includes UI screens, database helpers, and business logic  

- `lib/models/`  
  - Defines data models such as the Product model  

- `lib/database/`  
  - Handles SQLite database creation, queries, and updates  

- `lib/screens/`  
  - Contains different application screens such as the product list and add/edit screens  

- `pubspec.yaml`  
  - Manages dependencies and project configuration  

Each file is separated by responsibility to keep the project modular, readable, and maintainable.

## How to Run the Project

To run this project locally, follow these steps:

1. Clone the repository:
git clone https://github.com/muhammedozd/cs50-final-project-stock-management.git

2. Navigate into the project directory:
cd cs50-final-project-stock-management

3. Install dependencies:
flutter pub get

4. Run the application:
flutter run


Make sure Flutter is properly installed and configured on your system before running the application.

## Design Decisions

One important design decision was choosing **local storage instead of a cloud-based backend**. While cloud solutions offer synchronization across devices, they also increase complexity and require user authentication and constant internet connectivity. Since this project targets simplicity and offline usability, SQLite was the most appropriate choice.

Another design decision was to keep the user interface minimal and focused. Instead of adding complex analytics or charts, the application prioritizes clarity and speed. Users should be able to quickly understand their stock status and perform actions without unnecessary distractions.

## Academic Honesty

This project was developed entirely by me as my **CS50x Final Project**. All code was written by me, and no unauthorized collaboration or code copying was involved. Official documentation and online resources were used only for learning purposes, particularly for Flutter, SQLite, and user interface design concepts. Any AI-based tools were used strictly as learning aids and not as replacements for my own work.

## Conclusion

The Stock Management Application successfully meets the goals of the CS50 Final Project by solving a real-world problem with practical software. It demonstrates my understanding of programming concepts, application structure, database management, and user interface design. This project represents a meaningful conclusion to my CS50x journey and serves as a foundation for future improvements and more advanced applications.

   
