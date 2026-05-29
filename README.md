# 🚀 Fast Clean Generator

A powerful, interactive CLI tool designed to accelerate Flutter development by generating boilerplate code following **Clean Architecture** principles and **GetX** state management.

[![Dart CI](https://github.com/saeidparvizi/clean_arch_generator/actions/workflows/dart.yml/badge.svg)](https://github.com/saeidparvizi/clean_arch_generator/actions/workflows/dart.yml)
[![Pub Version](https://img.shields.io/pub/v/fast_clean_generator)](https://pub.dev/packages/fast_clean_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 🏗️ **Complete Layer Generation**: Automatically creates Domain, Data, and Presentation layers.
- 🎮 **Smart GetX Integration**: 
    - Generates **Plural Controllers** for list management.
    - Generates **Singular Controllers** for item details and editing.
    - Automatic **Binding** registration and dependency injection.
- 📦 **CRUD Support**: Choose which operations you need (List, Get, Add, Update, Delete).
- 📝 **JSON to Model**: Converts your JSON schema into robust Entities and Models with `fromJson`/`toJson`.
- 🛣️ **Smart Routing**: Automatically updates your application routes and pages.
- 💻 **Interactive CLI**: Friendly prompts to guide you through the feature creation process.
- ✅ **Enterprise Ready**: Includes comprehensive Unit and Integration tests.

---

## 📦 Installation

To use `fast_clean_generator` globally on your machine, run:

```bash
dart pub global activate fast_clean_generator
```

*(Or if installing directly from GitHub during development)*
```bash
dart pub global activate --source git https://github.com/saeidparvizi/clean_arch_generator
```

Make sure your `dart` path is configured correctly in your system's environment variables.

---

## 🚀 How to Use

1. Go to your Flutter project root.
2. Run the generator command:

```bash
# You can use either the full command or the short alias:
fast_clean_gen generate

# OR simply:
fcg generate
```

### 🛠️ Interactive Prompts

The tool will ask you for:
- **JSON Input**: Path to a `.json` file or a raw JSON string representing your data model.
- **Feature Name**: The name of the module (e.g., `booking`, `profile`).
- **Root Class**: The main class name in PascalCase (e.g., `Booking`, `User`).
- **CRUD Selection**: Which operations you want to implement.
- **Component Selection**: Fine-tune which files (Entities, UseCases, Controllers, etc.) should be generated.

---

## 📂 Generated Structure

The tool generates a clean, scalable folder structure:

```text
lib/features/your_feature/
├── data/
│   ├── data_sources/    # Remote API implementations
│   ├── models/          # JSON serialization logic
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business logic models (Equatable)
│   ├── repositories/    # Abstract interfaces
│   └── usecases/        # Single-responsibility logic units
├── presentation/
│   ├── bindings/        # GetX Dependency Injection
│   ├── controllers/     # Plural & Singular controllers
│   ├── pages/           # List, Add, Edit & Detail screens
│   └── widgets/         # Feature-specific forms & dialogs
└── routes/              # Local feature routes
```

---

## 📋 Example JSON Schema

Save this as `model.json` to test the generator:

```json
{
  "id": 1,
  "title": "Clean Architecture",
  "is_completed": false,
  "priority": "high",
  "created_at": "2023-12-31"
}
```

---

## ✅ Quality Assurance

This project is built with stability in mind:
- **Linting**: Strictly follows Dart's recommended analysis options.
- **Testing**: 35+ Unit and Integration tests covering naming logic, JSON parsing, and code generation.
- **CI/CD**: Automated GitHub Actions to verify every commit.

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request on GitHub.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ☕ Support

If you find this tool helpful, consider giving it a ⭐ on [GitHub](https://github.com/saeidparvizi/clean_arch_generator)!

Developed with ❤️ by [Saeid Parvizi](https://github.com/saeidparvizi)
