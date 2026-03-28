# Living Way Knowledge (public texts)

Canonical source for **public** Living Way texts used by the marketing site and the app.

## Directory layout

```text
living-way-knowledge/
  Core/                    # Shared doctrine, guide texts, cross-tradition content
  Laozi/                   # One folder per guide / teacher / tradition
  Gotama/
  Krishna/                 # Gita, Madālasā lullaby, Śiva-saṅkalpa Suktam, etc.
  Einstein/
  Architect/

  *.tex                    # Curated publication / anthology sources
  *.html                   # Generated HTML outputs served by the site sync
  *.pdf                    # Generated PDF outputs served by the site sync
  index.html               # Shared library shell
  read.html                # Shared markdown reader

  tools/                   # Build helpers + `sync-public-knowledge.sh` / `public-knowledge-rsync.excludes`
  templates/               # Pandoc templates
```

- **Canonical source texts:** `Core/` and the guide folders (`Laozi/`, `Gotama/`, `Krishna/`, ...).
- **Publication sources:** root `.tex` files for curated compilations.
- **Generated outputs:** root `*.html` and `*.pdf` from `run.sh` / `tools/build_html.sh` and `pdflatex`.

See [GUIDE_ORGANIZATION.md](GUIDE_ORGANIZATION.md) for the canonical content model, public/private boundaries, and integration rules for `../living-way-site` and `../living-way-app`.

## Build

```bash
./run.sh
```

- Compiles `The_Living_Way.tex`, `The_Living_Suttas.tex`, `The_Living_Architecture.tex` to PDF.
- Runs `tools/build_html.sh` to generate HTML from `.tex` and the guide Markdown.

## Sync to site and app

**Canonical rsync** is implemented once in **`tools/sync-public-knowledge.sh`**, with exclude patterns in **`tools/public-knowledge-rsync.excludes`**.

```bash
# Site (from living-way-site/)
./scripts/sync-public-knowledge.sh

# App (from living-way-app/)
./scripts/sync-public-knowledge.sh
# or: ./run.sh sync-knowledge

# Direct (from this repo — any destination)
./tools/sync-public-knowledge.sh /path/to/public-knowledge/
```

Run after changing canonical content, **`index.html`** / **`read.html`**, or rebuilding HTML/PDF so consumers serve the latest. The sync copies the whole knowledge tree, including the library index.

## Deployment

This repo is **not deployed by itself** in the main workflow. Content is consumed by:

1. **Marketing site** — Synced into **living-way-site**’s `public-knowledge/`; treat that copy as publishing output, not the primary authoring location.
2. **App** — The app consumes this repo’s public content and keeps any private overlays in its own gitignored locations; no separate deploy of this repo is required.

**Optional: GitHub Pages for a standalone library**  
If you want a separate URL that serves only this repo (e.g. a preview or standalone library), enable GitHub Pages in this repo: **Settings → Pages → Source: Deploy from a branch** (e.g. `main`, `/ (root)`). The root contains `index.html` and the built `.html`/`.pdf` files. Ensure you run `./run.sh` and commit the built files (or use a CI job to build and deploy) so the Pages site is up to date.
