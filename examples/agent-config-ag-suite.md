# agent-config.md — AG-Suite
# Leído por todos los agentes al arrancar.
# Complementa CLAUDE.md con configuración específica del sistema multiagente.

---

## 🎯 Proyecto

```
nombre=AG-Suite
descripcion=Plataforma SaaS B2B modular y multi-tenant
tipo=saas
estado=activo
```

---

## 🛠 Stack

```
backend=Laravel 12 + PHP 8.3 + nwidart/laravel-modules
frontend=Vue 3 (Composition API + Script Setup) + Inertia.js 2.0
base_datos=MySQL 8 (Single DB multi-tenant)
estilos=Tailwind CSS v4 + Shadcn-vue + Lucide Icons
otros=spatie/laravel-permission, laravel-vue-i18n, stripe/stripe-php
```

---

## 📁 Estructura de carpetas

```
adr=docs/adr/
issues=docs/issues/
contracts=docs/contracts/
features=docs/features/
context=docs/PROJECT_CONTEXT.md
superpowers_plans=docs/superpowers/plans/
superpowers_specs=docs/superpowers/specs/
```

---

## 📋 Convenciones

```
idioma_commits=español
formato_commits=<tipo>(<módulo>): <descripción en español> (<referencia>)
tipos_commits=feat, fix, refactor, docs, test, chore
idioma_codigo=español
```

Ejemplos de commits:
- `feat(saas): se implementa administración de roles (ADR-005)`
- `fix(core): se corrige asignación de permisos en seeders (BUG-001)`
- `docs(adr): se documenta enmienda 2 de ADR-005`

---

## 🌲 Git y ramas

```
branch_target=main
branch_formato=feature/adrXXX-nombre-completo
```

---

## 👥 Roles activos

```
rol_backend=si
rol_frontend=si
rol_qa=si
rol_contexto=si
rol_documentador=si
```

---

## ✅ Definición de terminado

```
tests_requeridos=unitarios, integración
cobertura_minima=
lint_obligatorio=si
analisis_estatico=no
```

---

## 📖 Lectura obligatoria por rol

### Orquestador — leer al arrancar:
- `docs/PROJECT_CONTEXT.md`
- `docs/adr/README.md`
- `docs/contracts/README.md`

### Backend — leer al arrancar:
- `docs/sistema-multi-idioma.md`
- `docs/sistema-tenant/tenant-helper.md`
- `docs/sistema-tenant/tenant-scope.md`
- `docs/contracts/rules/permisos.md`

### Frontend — leer al arrancar:
- `docs/sistema-multi-idioma.md`
- `docs/features/estandar-formularios.md`
- `docs/features/estructura.md`
- `docs/componentes/Uso-data-tables.md`

### Contexto — leer al arrancar:
- `docs/PROJECT_CONTEXT.md`

### Documentador — leer al arrancar:
- `docs/features/README.md` (si existe)
- `docs/contracts/README.md`

---

## 🧩 Componentes y patrones clave

### Backend

**Multi-tenancy** — OBLIGATORIO en modelos de empresa:
```php
// Columna empresa_id + trait TenantScope en modelos multi-tenant
// Contexto actual siempre vía TenantHelper::current() — nunca tenant.current
use Modules\Core\App\Traits\TenantScope;

class MiModelo extends Model
{
    use TenantScope;
}
```

**RBAC — spatie/laravel-permission:**
```php
// Tres scopes obligatorios: saas | template | empresa
// saas = roles globales del panel SuperAdmin
// template = plantillas para nuevas empresas
// empresa = roles vivos en un tenant específico
```

**Emails con queue — capturar locale SIEMPRE:**
```php
use Illuminate\Support\Facades\App;

public function __construct(/* ... */)
{
    // ... asignar propiedades ...
    $this->locale(App::getLocale()); // ← SIEMPRE al final del constructor
}
```

**Namespaces — mayúscula siempre:**
```php
// ✅ Correcto
Modules\Core\App\Models\Cliente

// ❌ Incorrecto
modules\core\app\models\cliente
```

### Frontend

**Layouts — NUNCA mezclar:**
```vue
<!-- Panel empresa/cliente -->
import AppLayout from '@/layouts/AppLayout.vue'

<!-- Panel SaaS Admin -->
import SaasLayout from '@/layouts/SaasLayout.vue'
```

**Formularios — patrón OBLIGATORIO:**
```vue
<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'
import { useFormSubmit } from '@/composables/useFormSubmit'
import FormField from '@/components/ui/FormField.vue'

const form = useForm({ campo: '' })
const { submit, isProcessing } = useFormSubmit(form, {
    method: 'post',
    url: route('modulo.store'),
    messages: {
        loading: 'Guardando...',
        success: 'Guardado correctamente',
    },
})
</script>

<template>
    <form @submit.prevent="submit" class="space-y-8">
        <div class="grid grid-cols-12 gap-4">
            <FormField
                id="campo"
                v-model="form.campo"
                :label="$t('modulo.campo')"
                :error="form.errors.campo"
                :disabled="isProcessing"
                class="col-span-12 md:col-span-6"
            />
        </div>
        <Button type="submit" :disabled="isProcessing">Guardar</Button>
    </form>
</template>
```

**Grid de 12 columnas — estándar del proyecto:**
```vue
class="col-span-12"                        <!-- 100% -->
class="col-span-12 md:col-span-6"          <!-- 50% desde md -->
class="col-span-12 md:col-span-4"          <!-- 33% desde md -->
```

**SelectTrigger — siempre `w-full` en grid/flex:**
```vue
<SelectTrigger class="w-full">...</SelectTrigger>
```

**Tablas — DataTable obligatorio:**
```vue
import DataTable from '@/components/DataTable.vue'
import { createColumnHelper } from '@tanstack/vue-table'
// Usar siempre h() de Vue para renderizar componentes en celdas
```

**Toasts:**
```vue
import { useToast } from '@/composables/useToast'
// Toast ya montado en AppShell — solo usar el composable
```

**Permisos en menú — NO negociable:**
```vue
const permissions = computed<string[]>(() => (page.props.auth as any).permissions ?? [])
const can = (p: string) => permissions.value.includes(p)

// Todo item de ruta protegida:
...(can('nombre-permiso') ? [{ title: 'Item', href: ruta() }] : [])
```

**i18n — SIEMPRE ambos idiomas:**
```vue
<!-- Templates -->
$t('modulo.clave')

<!-- Agregar en AMBOS archivos: -->
<!-- Modules/[Modulo]/lang/es.json -->
<!-- Modules/[Modulo]/lang/en.json -->
```

---

## ⚙️ Comandos de desarrollo

```bash
# Levantar entorno completo
composer dev

# Tests
composer test
php artisan test --filter NombreDelTest

# Build assets
npm run dev        # modo watch
npm run build      # producción

# Linting
npm run lint
npm run format

# Artisan útiles
php artisan module:list
php artisan route:list --path=saas
php artisan queue:work
```

---

## 🔌 Perfil OPT-IN — API REST con OpenAPI

Aplica **solo al carril REST** (rutas de `api.php` con token, para apps y
terceros). NO aplica al tráfico Inertia (props a páginas), cuya disciplina
contract-first es aparte: DTOs tipados → tipos TS, sin OpenAPI.

```
rest_openapi=on
spec_ubicacion=docs/api/v{N}/
generador=Scramble
generador_config=config/scramble.php
diff_breaking=oasdiff
cliente_tipado=on
dictamen_reviewer=consultivo
rondas_maximas=2
trigger_agentes=recurso público nuevo, v2, o invocación manual sobre superficie existente
```

### Convenciones de plataforma de la API

```
api_auth=Bearer token (Sanctum)
api_forma_errores=shape nativo de Laravel { "message", "errors" } — NO migrar a problem+json
api_paginacion=shape nativo del paginador de Laravel
api_versionado=/v{N} en URL; v1 estable, breaking sube a v2, v1 con soporte >=12 meses, deprecaciones intra-v1 con header Sunset >=90 días (ADR-030)
api_scope_tenant=header X-Empresa-Id, presente solo en rutas con middleware tenant; un token puede operar sobre varias empresas (ADR-030)
api_glosario=Tenant (tabla clientes) = la cuenta SaaS/billing; Empresa = la unidad real de aislamiento y lo que scopea X-Empresa-Id
```

⚠️ Endpoints con lógica dinámica (valores centinela en `role`, merge de catálogos,
`permissions[]` condicionales) requieren pistas PHPDoc u overrides de schema: el
generador no los infiere solo.

---

## 🚨 Reglas críticas del proyecto

- **Multi-tenancy**: toda operación de datos debe respetar `empresa_id` + `TenantScope` + `TenantHelper::current()`
- **i18n**: todo texto visible (UI, emails, validaciones) debe estar en `es.json` Y `en.json` — nunca hardcodear
- **Permisos en menú**: si una ruta tiene middleware `permission:X`, el item de menú debe tener `can('X')` — no basta proteger solo el backend
- **Commits**: los agentes commitean solos en la branch del ADR — el gate está en el PR y el merge. Flujo: Implementar → Commitear → QA → Reportar → Revisión de Angel → Aprobación → Docs → Angel autoriza el PR → Angel mergea
- **Branch**: una por ADR completo — formato `feature/adrXXX-nombre-completo`
- **Emails con queue**: capturar locale en constructor con `$this->locale(App::getLocale())`
