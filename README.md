# BeerNotebook

A premium mobile application designed for beer enthusiasts to discover, taste, and archive their personal beer collections.

This project represents a complete architectural redesign and migration from **React Native** to **Flutter/Dart**, prioritizing performance, scalability, and a modern Material 3 user experience.

## 📱 Project Overview

BeerNotebook allows users to build a digital library of their beer-tasting journey. Whether it's a rare craft ale or a local favorite, users can save detailed notes, ratings, and brewery information.

### Key Features
* **Personal Collection:** Manage a massive library of tasted beers with optimized performance.
* **Wishlist:** Keep track of beers you want to try next.
* **Material 3 Design:** A sleek, adaptive UI using the latest Flutter components.
* **Architecture-First:** Built with a clean **MVVM (Model-View-ViewModel)** pattern and **Feature-First** structure for long-term maintainability.

---

## 🏗️ Architecture & Tech Stack

The application is engineered to handle large datasets and complex states with a modular approach:

* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Architecture Pattern:** MVVM (Model-View-ViewModel)
* **Backend Communication:** RESTful API (Node.js) via `http` services.
* **Project Structure:** Feature-based organization (e.g., `features/beer`, `features/auth`).

### Directory Structure

```text
lib/
├── core/               # Shared logic, API clients, and global services
├── features/           # Domain-specific logic (Auth, Beer, Home, Navigation)
│   ├── [feature]/
│   │   ├── [feature]_model.dart
│   │   ├── [feature]_view.dart
│   │   └── [feature]_view_model.dart
└── main.dart           # App entry point and Provider injection
```

## 🛡️ License & Legal Protection

**Copyright (c) 2026 BeerNotebook - All Rights Reserved.**

**CONFIDENTIAL AND PROPRIETARY.**

This software and its source code are the sole property of the author. Access to this repository or viewing of the source code does not grant any rights to the user.

* **Prohibition of Copying:** Unauthorized copying of this project, or any portion thereof, via any medium is strictly prohibited.
* **Prohibition of Distribution:** Any distribution of this code, whether in its original or modified form, is strictly prohibited without the express prior written consent of the copyright owner.
* **Proprietary Architecture:** The architectural implementation (MVVM Feature-First) and logic flow are considered trade secrets and intellectual property.
* **Legal Action:** Any infringement of these terms, including unauthorized cloning, reverse-engineering, or redistribution, will be prosecuted to the maximum extent permitted by intellectual property law.