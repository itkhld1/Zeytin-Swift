# 🌿 Zeytin (Smart Harvest)

**Zeytin** is an AI-powered mobile assistant designed to empower olive farmers and enthusiasts. Developed with a focus on the rich olive heritage of the Aegean region, Zeytin uses on-device Machine Learning to provide real-time insights into olive health and harvest readiness.

Designed in **Denizli**, Zeytin is built to be **100% offline**, ensuring farmers can use it even in the most remote groves.

---

## ✨ Features

- **🔍 AI-Powered Scanning:**
  - **Live Scan:** Real-time classification of olives using the device camera.
  - **Photo Scan:** Analyze existing photos for deep health inspection.
- **📉 Harvest Roadmap:**
  - **Ripeness Tracking:** Identifies stages from *Green* to *Veraison* to *Black*.
  - **Quality Insights:** Guidance on whether olives are best for premium liquid gold (oil) or traditional brining.
- **🪲 Pest & Disease Intelligence:**
  - Detects common threats like Olive Fruit Fly or Peacock Spot.
  - Provides detailed symptoms and mitigation strategies.
- **🇹🇷 Local Expertise:**
  - Built-in database for famous Turkish varieties: **Gemlik**, **Ayvalık (Edremit)**, **Memecik**, and **Domat**.
- **🛠 Polished UX:**
  - Smooth SwiftUI interface with responsive design for iPhone and iPad.
  - Tactile haptic feedback for a premium feel.

---

## 🚀 Tech Stack

- **Language:** Swift 6.0
- **Framework:** SwiftUI
- **Machine Learning:** CoreML (Custom `OliveClassifier` model)
- **Vision:** AVFoundation for real-time camera processing
- **Platform:** iOS 16.0+

---

## 📦 Installation & Setup

Since this is a **Swift Playground App (.swiftpm)**, you can open it in multiple ways:

### 1. Swift Playgrounds (iPad & Mac)
- Download or clone this repository.
- Open `Package.swift` or the project folder directly in Swift Playgrounds.
- Tap **"Run"** to start exploring.

### 2. Xcode (Mac)
- Open the project folder in Xcode.
- Xcode will automatically resolve the package dependencies.
- Select your iPhone/iPad or a Simulator (iOS 16+) and press **Cmd + R**.

---

## 📖 How It Works

1. **Launch:** Start at the Welcome screen and tap **"Start Analysis"**.
2. **Scan:** Use the **Live Scan** to point your camera at an olive branch.
3. **Analyze:** The AI will instantly tell you the ripeness level or identify if a pest is present.
4. **Roadmap:** Check the **Harvest Roadmap** to see your overall harvest readiness percentage based on your scan history.
5. **Report:** If pests are detected, a red alert button appears, leading you to a detailed **Pest Report**.

---

## 🛡 Privacy

Zeytin is designed with privacy at its core. **All processing happens on-device.** No images, location data, or scan results are ever sent to a server. 

---

## 👨‍💻 Author

Developed by **Ahmad Khaled Samim** for the **WWDC26 Swift Student Challenge**.

*Designed and Developed in Denizli, Turkey.*
