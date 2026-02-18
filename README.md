# 🤖 My AI Infrastructure: OpenClaw Setup

This repository contains the Docker configuration for your private AI agent pod. It runs the **OpenClaw** orchestrator alongside the official **OpenClaw Browser** sidecar (Chromium + CDP), managed via a `Makefile` for convenience.

## 🗂 Project Structure

* `docker-compose.yml`: Defines the `openclaw-me` and `browser` services on a shared network.
* `Makefile`: Shortcut commands for setup, lifecycle management, and maintenance.
* `.env`: (Ignored by Git) Stores your secrets.
* `data/`: Persistent storage for OpenClaw's internal database and settings.
* `workspace/`: The local "sandbox" where the AI can create and edit files.
* `SECURITY.md`: Security policy, self-hosting warnings, and responsible disclosure process.

## 🚀 Getting Started

### 1. Prerequisites

* **OrbStack** (recommended for MacBook Pro/Mac mini) or Docker Desktop.
* **Python 3** (for `pre-commit`, installed automatically during setup).

### 2. Configure Environment Variables

`make setup` will copy `.env.example` to `.env` on first run. Edit the resulting `.env` file and fill in your values:

```text
ANTHROPIC_API_KEY=your_anthropic_api_key
AUTH_PASSWORD=your_dashboard_password
OPENCLAW_GATEWAY_TOKEN=your_secure_hex_token
OPENCLAW_GATEWAY_TRUSTED_PROXIES=127.0.0.1,host.docker.internal
```

### 3. Run Setup

This creates the `data/` and `workspace/` volume folders, installs `pre-commit` hooks, and scaffolds your `.env`:

```bash
make setup
```

### 4. Launch the Pod

```bash
make up
```

## 🛡 Safe AI Development

This project is built with a **Security-First** approach to protect your infrastructure while experimenting with autonomous agents:

* **Secret Protection**: Automatic `pre-commit` hooks are installed during `make setup` to scan for and block accidental commits of API keys or the `.env` file.
* **Workspace Sandbox**: All AI-generated files and downloads are confined to the `workspace/` directory, which is git-ignored to prevent "repo bloat" and accidental leakage of AI-retrieved data.
* **Git Integrity**: The `make clean-workspace` command automatically resolves common Git "submodule" errors (e.g., *'workspace/' does not have a commit checked out*) caused by agents initializing their own Git repos.
* **Local-Only Identity**: Configuration files like `openclaw.json` are kept in the ignored `data/` folder, ensuring your agent's digital identity stays on your machine.

## 🔗 Accessing the Dashboard

OpenClaw will be available at:
👉 **`http://localhost:18789`** (or `http://openclaw-me.<project-dir>.orb.local` if using OrbStack).

### First-Time Login / Session Reset

To pair your browser session and bypass authentication loops, use the unique URL printed by `make up`:

```
http://localhost:18789/?token=YOUR_GATEWAY_TOKEN
```

## 🛠 Makefile Commands

| Command | Description |
|---|---|
| `make setup` | Initial install: creates volumes, installs pre-commit, scaffolds `.env` |
| `make up` | Launch containers and print access URLs |
| `make stop` | Pause containers (fast resume, data preserved) |
| `make down` | Remove containers (clean teardown) |
| `make restart` | Full restart (`down` + `up`) |
| `make status` | Show running container health and ports |
| `make logs` | Stream real-time logs from all services |
| `make clean-workspace` | Wipe all files the AI created in `workspace/` |
