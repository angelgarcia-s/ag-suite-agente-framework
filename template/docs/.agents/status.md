# Pipeline Status
# Canal de comunicación entre agentes.
# Formato: clave=valor — NO usar markdown ni bloques de código al escribir.
# Solo el Orquestador actualiza el estado de otros agentes.
# Cada agente actualiza su propio campo al terminar su fase.

# ─── ADR Activo ──────────────────────────────────────────────────────────────
adr=
titulo=
branch=
api_contract=
iniciado=

# ─── Estado por agente ───────────────────────────────────────────────────────
# Valores válidos: idle | ready | in_progress | done | needs_fix
orchestrator=idle
backend=idle
frontend=idle
contexto=idle
featuredocs=idle

# ─── Issues ──────────────────────────────────────────────────────────────────
backend_issues=
frontend_issues=
completados=

# ─── Handoff ─────────────────────────────────────────────────────────────────
# Fases válidas: backend_review | frontend_ready | full_review | awaiting_human | docs_parallel | pr_ready
handoff_phase=
handoff_message=
handoff_from=
handoff_to=

# ─── Blocker ─────────────────────────────────────────────────────────────────
blocker_agente=
blocker_detalle=

# ─── Aprobación humana ───────────────────────────────────────────────────────
# Valores válidos: pending | approved | rejected
aprobacion=pending
aprobado_por=
nota=
