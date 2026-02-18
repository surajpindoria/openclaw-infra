# SPDX-License-Identifier: Apache-2.0

# --- Terminal Colors ---
BLUE   := $(shell tput setaf 4)
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RED    := $(shell tput setaf 1)
BOLD   := $(shell tput bold)
RESET  := $(shell tput sgr0)

# --- Dynamic Configuration ---
PROJECT_DIR    := $(notdir $(shell pwd))
# Dynamically pulls the primary container name from your compose file
CONTAINER_NAME := $(shell grep 'container_name:' docker-compose.yml | head -n 1 | sed 's/.*container_name: //')

ORB_URL        := http://$(CONTAINER_NAME).$(PROJECT_DIR).orb.local
LOCAL_URL      := http://localhost:18789

.DEFAULT_GOAL := help

# --- Help Menu ---
.PHONY: help
help:
	@echo ""
	@echo "$(BOLD)🤖 OpenClaw Pod Management Commands$(RESET)"
	@echo "------------------------------------------------"
	@echo "  $(BLUE)make setup$(RESET)             Initial install & volume creation"
	@echo "  $(BLUE)make up$(RESET)                Launch containers (Online)"
	@echo "  $(BLUE)make stop$(RESET)              Pause containers (Fast Resume)"
	@echo "  $(BLUE)make down$(RESET)              Remove containers (Clean Teardown)"
	@echo "  $(BLUE)make restart$(RESET)           Full restart (down + up)"
	@echo "  $(BLUE)make status$(RESET)            Check container health"
	@echo "  $(BLUE)make clean-workspace$(RESET)   Wipe AI-generated files & fix Git"
	@echo "  $(BLUE)make logs$(RESET)              View real-time logs"
	@echo ""

# --- Setup & Installation ---
.PHONY: setup
setup:
	@echo "$(BOLD)$(BLUE)🏗️  STARTING SETUP$(RESET)"
	@if [ -z "$(CONTAINER_NAME)" ]; then \
		echo "$(RED)❌ Error: container_name not found in docker-compose.yml$(RESET)"; exit 1; \
	fi

	@echo "$(YELLOW)📁 Ensuring local volumes exist...$(RESET)"
	@mkdir -p data workspace
	@touch data/.gitkeep workspace/.gitkeep

	@echo "$(YELLOW)📦 Installing security tools (User Mode)...$(RESET)"
	@python3 -m pip install pre-commit --user
	@python3 -m pre_commit install > /dev/null

	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)📄 Created .env from example. PLEASE EDIT IT NOW.$(RESET)"; \
	else \
		echo "$(BLUE)ℹ️  .env already exists.$(RESET)"; \
	fi

	@echo ""
	@echo "$(BOLD)$(GREEN)✅ SETUP COMPLETE!$(RESET)"
	@echo ""

# --- Operations ---
.PHONY: up stop down restart status logs clean-workspace

up:
	@echo "$(BLUE)🚀 Starting services...$(RESET)"
	@docker compose up -d
	@echo ""
	@echo "$(BOLD)$(GREEN)✨ SERVICES ARE ONLINE$(RESET)"
	@echo "------------------------------------------------"
	@echo "OrbStack:  $(BLUE)$(ORB_URL)$(RESET)"
	@echo "Localhost: $(BLUE)$(LOCAL_URL)$(RESET)"
	@echo ""
	@echo "$(BOLD)$(YELLOW)🔑 FIRST-TIME LOGIN / SESSION RESET:$(RESET)"
	@echo "Paste this URL once to pair your session:"
	@echo "$(BLUE)$(ORB_URL)/?token=$$(grep OPENCLAW_GATEWAY_TOKEN .env | cut -d '=' -f2)$(RESET)"
	@echo "------------------------------------------------"
	@echo ""

stop:
	@echo "$(YELLOW)⏸️  Stopping containers...$(RESET)"
	@docker compose stop
	@echo "$(BLUE)✅ Stopped.$(RESET)"
	@echo ""

down:
	@echo "$(RED)🛑 Tearing down environment...$(RESET)"
	@docker compose down
	@echo "$(BLUE)👋 Done.$(RESET)"
	@echo ""

restart:
	@$(MAKE) down
	@$(MAKE) up

status:
	@echo ""
	@echo "$(BOLD)$(BLUE)📊 SYSTEM STATUS$(RESET)"
	@echo "------------------------------------------------"
	@$(eval COMPOSE_PROJECT := $(shell docker compose ps -q | xargs docker inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' | head -n 1))
	@if [ -n "$(COMPOSE_PROJECT)" ]; then \
		docker ps --filter "label=com.docker.compose.project=$(COMPOSE_PROJECT)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"; \
	else \
		echo "$(RED)No containers currently running for this project.$(RESET)"; \
	fi
	@echo "------------------------------------------------"
	@echo "Files in Workspace: $(YELLOW)$$(find workspace -type f | wc -l)$(RESET)"
	@echo "Project Directory:  $(YELLOW)$(PROJECT_DIR)$(RESET)"
	@echo ""

clean-workspace:
	@echo "$(RED)🧹 Wiping AI workspace & fixing Git locks...$(RESET)"
	@rm -rf workspace/.git
	@find workspace -mindepth 1 ! -name '.gitkeep' -delete
	@echo "$(GREEN)✨ Workspace is clean.$(RESET)"
	@echo ""

logs:
	@docker compose logs -f
