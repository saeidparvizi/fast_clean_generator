# 🚀 Flutter Clean Architecture Generator

A powerful, interactive CLI tool designed to accelerate Flutter development by generating boilerplate code following **Clean Architecture** principles and **GetX** state management.

[![Pub Version](https://img.shields.io/pub/v/clean_arch_generator)](https://pub.dev/packages/clean_arch_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- 🏗️ **Full Layer Generation**: Automatically creates Domain, Data, and Presentation layers.
- 📦 **CRUD Support**: Choose which operations you need (List, Get, Add, Update, Delete).
- 🎮 **GetX Integration**: Generates Controllers, Bindings, and Pages pre-configured with GetX.
- 📝 **JSON to Model**: Converts your JSON schema into robust Entities and Models with `fromJson`/`toJson`.
- 🛣️ **Smart Routing**: Automatically updates your application routes and pages.
- 💻 **Interactive CLI**: Friendly prompts to guide you through the feature creation process.
- 🛠️ **Customizable**: Choose exactly which components to generate (Entities, UseCases, Forms, etc.).

---

## 📦 Installation

To use `clean_arch_generator` globally on your machine, run:

```bash
dart pub global activate clean_arch_generator
```

Make sure your `dart` path is configured correctly in your system's environment variables.

---

## 🚀 How to Use

1. Navigate to your Flutter project's root directory.
2. Run the generator command:

```bash
clean_arch_generator generate
```

### 🛠️ Interactive Prompts

The tool will ask you for:
- **JSON Input**: Path to a `.json` file or a raw JSON string representing your data model.
- **Feature Name**: The name of the module (e.g., `booking`, `profile`).
- **Root Class**: The main class name in PascalCase (e.g., `User`, `Order`).
- **CRUD Selection**: Which operations you want to implement.
- **Component Selection**: Fine-tune which files (Entities, UseCases, Controllers, etc.) should be generated.

---

## 📂 Generated Structure

The generator follows a standard Clean Architecture structure:

```text
lib/features/your_feature/
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bindings/
│   ├── controllers/
│   ├── pages/
│   └── widgets/
└── routes/
```

---

## 📋 Example JSON Schema

Save this as `model.json` to test the generator:

```json
{
  "id": 1,
  "title": "Task Title",
  "description": "Task Description",
  "is_completed": false,
  "due_date": "2023-12-31"
}
```

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
