# Example Usage

This directory demonstrates the default convention used by **Fast Clean Generator**.

## Quick Start

To see the generator in action without affecting your main project, you can run it directly inside this `example` directory:

1. Open your terminal in the `example/` folder.
2. Run the generator:
   ```bash
   fast_clean_gen generate
   ```
3. When prompted for the JSON path, simply press **Enter**. It will use the default path: `tool/schema.json` (which already exists in this folder).
4. Follow the interactive prompts (e.g., Feature: `todo`, Class: `Todo`).

The generator will create a `lib/` directory inside this `example` folder with all the Clean Architecture layers.

## Using in your own project

If you want to use the default settings in your Flutter project:

1. Create a `tool/` directory in your project root.
2. Place your JSON schema there and name it `schema.json`.
3. Run `fcg generate` and press **Enter** for the path.
