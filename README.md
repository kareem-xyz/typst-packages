# typst-packages

A personal collection of local packages, templates, and utilities for [Typst](https://typst.app/), a modern markup-based typesetting system.

## Setup

Typst resolves `@local` packages from a system-specific directory. Clone this repository directly into your platform's local package location:

- **Linux:** `~/.local/share/typst/packages/local`
- **macOS:** `~/Library/Application Support/typst/packages/local`
- **Windows:** `%APPDATA%\typst\packages\local`

For more details on package resolution, see the [official Typst packages documentation](https://github.com/typst/packages).

### Quick Install (Linux)

```bash
mkdir -p ~/.local/share/typst/packages
git clone git@github.com:kareem-xyz/typst-packages.git ~/.local/share/typst/packages/local
```

## Structure

Each package follows Typst's semantic versioning directory format:

```text
local/
└── <package-name>/
    └── <version>/
        ├── typst.toml
        └── lib.typ
```

## Usage

Import any package from this repository using the `@local` namespace:

```typst
#import "@local/<package-name>:<version>": *
```
