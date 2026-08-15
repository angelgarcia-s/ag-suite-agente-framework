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
make qa
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

**Si tu herramienta soporta mensajería entre sesiones, no tienes que hacer nada:**
el Orquestador descubre las sesiones abiertas y activa a cada agente por mensaje
cuando le toca. Los agentes le avisan de vuelta al terminar o al bloquearse, así
que la cadena avanza sola y tú solo intervienes en el gate.

**Si no está disponible**, el flujo cae al poll manual: cuando el Orquestador
notifique que un agente tiene trabajo, ve a esa terminal y escribe:
```
poll
```
El agente lee `status.md`, detecta su estado `ready` y arranca.

La detección es automática y conductual: el Orquestador intenta usar la
mensajería y, si no la tiene, te avisa que tendrás que hacer poll. No hay nada
que configurar ni versión que revisar.

> **Los nombres de las terminales son la dirección de cada agente.** Se generan
> en `scripts/iniciar-agente.sh` con el formato `<proyecto> | <etiqueta>`. Si
> cambias ese formato, el Orquestador deja de encontrar a los demás y todo cae al
> poll manual.

**`status.md` sigue siendo la fuente de verdad.** El mensaje solo avisa; el estado
vive en el archivo. Por eso un agente que se reinicia retoma sin perder nada, y
por eso los modos sesión única y Copilot funcionan igual sin mensajería.

### 3. Gate de aprobación humana

Los agentes commitean solos conforme avanzan — no esperes a autorizar commits.
El gate es tuyo en dos momentos: **la revisión** y luego **el PR y el merge**.

Cuando el pipeline llegue a `awaiting_human`, prueba el feature en el navegador/app
y revisa el código ya commiteado en la branch del ADR.

```
# En la terminal del Orquestador:
"aprobado"
# o
"bug: [descripción de lo que falló]"
```

### 4. Documentación y PR

Tras tu aprobación, el Orquestador activa Contexto y Documentador (documentan
código ya estable, así no rehacen trabajo si tu revisión pidió cambios):

```
# En terminal Contexto:
poll

# En terminal Documentador:
poll

# Cuando ambos terminen, en terminal Orquestador:
poll
```

El Orquestador te pedirá autorización para crear el PR. Sin tu indicación
explícita no lo crea — y el **merge lo haces tú**, nunca un agente.

---

## Comandos disponibles

```bash
make ayuda          # ver todos los comandos
make agentes        # lanzar todos en iTerm2
make orquestador    # agente individual
```
