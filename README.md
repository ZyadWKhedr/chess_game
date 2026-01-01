# ♟️ Flutter Grandmaster Chess

A premium, feature-rich chess application built with Flutter. Experience a professional chess environment with advanced rules, stunning aesthetics, and a smooth user experience.

## ✨ Features

### 🏆 Gameplay & Rules
- **Advanced Chess Rules**: Fully implemented **Castling**, **En Passant**, and **Pawn Promotion** with a dedicated selection UI.
- **Move Validation**: Precise legal move calculation including real-time check, checkmate, and draw detection (stalemate).
- **Game Modes**:
  - 👥 **Local Multiplayer**: Play against a friend with an automatic board rotation feature designed for face-to-face play.
  - 🤖 **Solo vs AI**: Challenge a built-in AI with smooth "thinking" progress indicators.

### 🎨 Premium Aesthetics & UX
- **Tournament-Grade Visuals**: High-contrast chess pieces and a professional board palette designed for clarity and depth.
- **Integrated Coordinates**: Algebraic notation (A-H, 1-8) integrated directly into the squares for a modern, clutter-free look.
- **Juicy Animations**:
  - **Elastic Dialogs**: High-energy "Game over" popups with custom victory/draw iconography.
  - **CHECK Badge**: Animated high-contrast badge that scales up when the King is under attack.
- **Dark/Light Mode**: Seamless theme switching with persistent state.
- **Vibration Support**: Configured permissions for haptic feedback on Android and iOS.

### 🛠 Tech Stack
- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Responsive Layout**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)
- **Architecture**: Modular Clean Architecture with refactored, reusable widget components.
- **Testing**: Includes comprehensive unit tests for move validation logic and widget tests for key UI flows.

## 🚀 Getting Started

1. **Clone the Repo**:
   ```bash
   git clone https://github.com/ZyadWKhedr/chess_game.git
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the App**:
   ```bash
   flutter run
   ```

---
Built with ❤️ by Zyad Khidr.
