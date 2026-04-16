# Arranque — Modo Terminal (Claude Code)

Usa este modo cuando tengas múltiples terminales disponibles.
Cada agente corre en su propia sesión de Claude Code de forma paralela.

---

## Setup inicial

```bash
# Dar permisos (una sola vez tras instalar)
chmod +x scripts/iniciar-agente.sh
chmod +x scripts/lanzar-agentes-terminal.sh
```

---

## Lanzar todos los agentes

```bash
# iTerm2 con paneles (recomendado)
make agentes

# Terminal.app con ventanas separadas
make agentes-terminal
```

Claude arranca en cada terminal ya con su rol activo — no necesitas escribir nada.

---

## Lanzar un agente individual

```bash
make orquestador
make backend
make frontend
make contexto
make documentador
```

Útil para reabrir una terminal que se cerró o agotó tokens.

---

## Primer mensaje en cada terminal

El agente arranca automáticamente con su rol. Confirma que cargó correctamente — verás algo como:

```
Orquestador listo. Proyecto: [nombre] | ADR activo: ninguno | Pipeline: idle
```

---

## Flujo de trabajo

### 1. Iniciar un ADR

En la terminal del **Orquestador**:
```
"planea desde superpowers/plans/nombre-plan.md"
# o
"nuevo feature: [descripción]"
```

### 2. Activar cada agente

Cuando el Orquestador notifique que un agente tiene trabajo, ve a esa terminal y escribe:
```
poll
```
El agente lee `status.md`, detecta su estado `ready` y arranca automáticamente.

### 3. Gate de aprobación humana

Cuando el pipeline llegue a `awaiting_human`, prueba el feature en el navegador/app.

```
# En la terminal del Orquestador:
"aprobado para commit"
# o
"bug: [descripción de lo que falló]"
```

### 4. Cierre del ADR

```
# En terminal Contexto:
poll

# En terminal Documentador:
poll

# Cuando ambos terminen, en terminal Orquestador:
poll
```

---

## Comandos disponibles

```bash
make ayuda          # ver todos los comandos
make agentes        # lanzar todos en iTerm2
make orquestador    # agente individual
```
