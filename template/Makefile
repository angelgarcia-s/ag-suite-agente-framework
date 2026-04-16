# Sistema Multiagente — Makefile
# Uso: make [comando]

.PHONY: agentes agentes-terminal orquestador backend frontend contexto documentador ayuda

# ─── Lanzadores completos ────────────────────────────────────────────────────

agentes: ## Lanza todos los agentes en iTerm2 con paneles
	osascript scripts/lanzar-agentes-iterm.applescript

agentes-terminal: ## Lanza todos los agentes en Terminal.app (ventanas separadas)
	bash scripts/lanzar-agentes-terminal.sh

# ─── Agentes individuales ────────────────────────────────────────────────────

orquestador: ## Inicia solo el Orquestador
	bash scripts/iniciar-agente.sh orquestador

backend: ## Inicia solo el Backend
	bash scripts/iniciar-agente.sh backend

frontend: ## Inicia solo el Frontend
	bash scripts/iniciar-agente.sh frontend

contexto: ## Inicia solo el Contexto
	bash scripts/iniciar-agente.sh contexto

documentador: ## Inicia solo el Documentador
	bash scripts/iniciar-agente.sh documentador

# ─── Ayuda ───────────────────────────────────────────────────────────────────

ayuda: ## Muestra este menú
	@echo ""
	@echo "  Sistema Multiagente — Comandos disponibles"
	@echo ""
	@grep -E '^[a-záéíóúñA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-22s %s\n", $$1, $$2}'
	@echo ""

.DEFAULT_GOAL := ayuda
