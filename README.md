# OmniManager (Omni)

Omni is a local AI chat desktop app for Linux. It is a PySide6/QML front end over a Python backend that runs GGUF language models on your own machine through `llama-cpp-python`, so chats are not sent to a cloud service. Chat history, settings and logs are stored in SQLite. The project is an early work in progress (v0.1.0).

## Features

Implemented in the code today:

- **Streaming chat** with a local instruct model (`app/backend/ai/llm_engine.py`).
- **Prompt routing** (`app/backend/ai/orchestrator.py`): a keyword-based router picks one of three flows - a fast flow (instruct model only), a thinking flow (a "thinking" model produces reasoning, then the instruct model writes the answer), or a tool flow.
- **Chat history in SQLite**: chat list, messages, auto-generated chat titles, and summarisation of long chats (`databases/system_db.py`, `services/chat_service.py`).
- **Token budgeting**: the context window is split into system, chat, RAG, memory and reasoning budgets, and prompts are trimmed to fit (`llm_engine.py`, `prompt_builder.py`).
- **User memory database** (`databases/user_db.py`): memories stored with embeddings and searched by similarity; conversation summaries are saved as memories. A decay routine (`decay_memories`) exists but is not scheduled yet.
- **RAG building blocks** (`ai/rag_pipeline.py`): word-based chunking, `bge-small` embeddings via `sentence-transformers`, vectors stored as SQLite BLOBs, and cosine-similarity search with numpy.
- **File-search tool**: the model can call `search_files`, which matches file names under a configurable search path (`tools/search_files.py`). A small command router (`echo`, `help`, `files`, `apps`) also uses it and an XDG desktop-entry app finder.
- **Settings and logs pages**: settings (model parameters, RAG, tools, UI) are persisted in SQLite; logs are written to the database and shown in the UI.
- **Dev mode** (`--dev`): file watcher that hot-reloads QML and the Python backend.

Current limitations (see Roadmap):

- The Notes page is a placeholder, and the Database page is an empty skeleton.
- `web_search` appears in the tool registry but has no implementation.
- There is no UI or code path yet that ingests documents into the RAG store.
- Some code paths are known to be broken or untested: for example, the thinking flow passes the message list to `RAGPipeline.retrieve()` (which expects a string), and the tool flow is called with a keyword argument its signature does not accept. There are no automated tests.

## Architecture

```
app/
  main.py            Entry point: loads config/models.yaml, builds the backend, loads QML
  ui/                QML interface: main window, sidebar, pages (Chat, Notes, Logs, Settings, Database)
  state/             Small Python state objects exposed to QML (e.g. ChatState)
  backend/
    bridge.py        QObject bridge between QML and the backend; runs AI/system work off the UI thread
    command_router.py  Simple text commands (echo, help, files, apps)
    settings.py      Default settings, persistence through SQLite
    ai/              Model loading (model_manager), generation and streaming (llm_engine),
                     routing (orchestrator), prompt assembly (prompt_builder),
                     embeddings and RAG, identity text, vision model loader
    databases/       system_db.py (chats, messages, notes, logs, settings),
                     user_db.py (profile, memory, tasks, documents and chunks)
    services/        chat_service.py: chat cache, titles, summaries
    tools/           search_files, app discovery, tool registry (function-calling schema)
    system/          device_manager.py: CUDA/CPU detection
config/models.yaml   Which model files to load, and database locations
data/                Desktop entry, icon, AppStream metadata
docs/                Architecture notes and roadmap drafts
```

## Tech stack

- Python 3.12+
- PySide6 / Qt Quick (QML) for the UI
- llama-cpp-python for local GGUF inference
- sentence-transformers and PyTorch for embeddings (`bge-small-en-v1.5`)
- transformers and the DeepSeek Janus package for the vision model loader (loaded at startup, no image feature in the UI yet)
- SQLite (standard library `sqlite3`) and numpy
- pyxdg for desktop-entry lookup

## Setup & run

Model files are **not** included in this repository. You download them separately.

1. Use Python 3.12 or newer (`requires-python = ">=3.12"` in `pyproject.toml`) and create a virtual environment:

   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

   `requirements.txt` also notes the `janus` package (DeepSeek Janus), which `app/backend/ai/vision_manager.py` imports and which must be installed from its GitHub repository.

2. Download the models and place them under `models/` in the repository root (this folder is git-ignored). The paths below are the ones in `config/models.yaml`:

   | Name in config | Backend | Default path |
   | --- | --- | --- |
   | `instruct` | llama-cpp | `models/llama/LiquidAI_LFM2.5-1.2B-Instruct-GGUF_LFM2.5-1.2B-Instruct-Q4_K_M.gguf` |
   | `thinking` | llama-cpp | `models/llama/LiquidAI_LFM2.5-1.2B-Thinking-GGUF_LFM2.5-1.2B-Thinking-Q4_K_M.gguf` |
   | `vision` | vision | `models/vision/Janus-Pro-1.3B` (Hugging Face model folder) |
   | `bge-small` | embedding | `models/embeddings/bge-small-en-v1.5` (sentence-transformers folder) |

   To use different files, edit the `model:` path of the matching entry in `config/models.yaml`. Paths are relative to the directory you start the app from. `main.py` also checks `~/.local/share/omnimanager/models.yaml` first and uses it instead of `config/models.yaml` if it exists. All entries in the file are loaded at startup, including the vision model.

3. Run from the repository root (the config and model paths are relative to it):

   ```bash
   python app/main.py          # normal start
   python app/main.py --dev    # hot reload of QML/Python on file changes
   ```

   Databases are created automatically at `app/backend/app_data/system.db` and `user.db` (git-ignored; paths set in `config/models.yaml`).

The app has only been written against Linux (XDG desktop entries, `/usr/share/applications`).

## Roadmap

Planned, not implemented:

- Notes page (markdown editor); the database table and CRUD helpers exist, the UI does not.
- Vector index (e.g. FAISS) to replace the brute-force numpy search over SQLite BLOBs.
- Document ingestion for RAG.
- `web_search` tool.
- Automated tests and fixes for the known issues above.

See also [docs/ROADMAP.md](docs/ROADMAP.md).

## Screenshots

<!-- TODO: add screenshots -->

## Disclaimer

This project is open source and community driven. The core will stay open; some advanced features may later be offered under a commercial license. Licensed under Apache-2.0 (see `LICENSE`).
