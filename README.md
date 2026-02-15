# Out of Harm's Way 🛡️

**Google Solution Challenge 2024 Submission**

"Out of Harm's Way" is an innovative, interactive web application designed to raise awareness about digital safety and security, featuring a unique **hand-controlled navigation system** to make learning engaging and accessible.

## 🌟 Features

- **Interactive 3D Hero Section**: A stunning, fluid liquid sphere that reacts to user interaction, built with **Three.js** and **GLSL custom shaders**.
- **Hand Gesture Control**: Navigate the entire experience without touching the keyboard!
    - **Expand**: Open your hand to expand the sphere.
    - **Spin**: Move your hand left/right to spin the 3D model.
    - **Follow**: The sphere tracks your hand movement in real-time.
    - Powered by **MediaPipe Hands** and **TensorFlow**.
- **Scrollytelling Experience**: A smooth, narrative-driven interface that guides users through safety concepts.
- **Cross-Platform**: Built with **Flutter Web** for seamless performance across devices.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Web)
- **3D Graphics**: Three.js (JavaScript interoperability)
- **AI/ML**: MediaPipe Hands (via JavaScript)
- **State Management**: Flutter Riverpod
- **Animations**: Flutter Animate & Custom Shaders

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.0 or later)
- Google Chrome (for best WebGL and Camera support)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/out_of_harms_way.git
   cd out_of_harms_way
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome
   ```

## 🎮 How to Use Hand Control

1. Click the **"Enable Hand Control"** button on the home screen.
2. Allow camera access when prompted by the browser.
3. Use your hand to interact:
   - **Open Hand**: Expands the sphere.
   - **Fist**: Shrinks the sphere.
   - **Move Hand**: Rotates and moves the sphere.
4. Click **"Disable Hand Control"** to turn off the camera.

## 📁 Project Structure

- `lib/`: Main Flutter application code.
  - `presentation/`: UI screens and widgets.
  - `core/`: Theme, constants, and utilities.
- `web/`: Web-specific assets and scripts.
  - `three_scene.js`: Three.js logic for the 3D sphere.
  - `index.html`: Entry point and MediaPipe logic.

## 🤝 Contributing

This project is part of the Google Solution Challenge. We welcome feedback and suggestions!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
