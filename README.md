# CuentaHogar · Back-end (TP N° 1 — Programación IV)

Aplicación Ruby on Rails para el **control de gastos personal y del hogar**. Es el back-end de la PWA
CuentaHogar: los miembros de un hogar cargan gastos (con comprobante), registran ingresos, arman
presupuestos mensuales y reciben avisos de vencimientos.

El proyecto tiene dos partes separadas:

- **Back-office** (`/admin`): panel web para administradores, con autenticación nativa de Rails 8.
- **API JSON versionada** (`/api/v1`): la consume la aplicación del usuario final (TP N° 2). Autenticación por token.

**Deploy:** _(completar con la URL si se publica)_

---

## Requisitos

- Ruby 3.3 o superior
- Rails 8
- SQLite 3
- Git

## Instalación

```bash
git clone <URL-DEL-REPO> cuenta_hogar
cd cuenta_hogar
bundle install
bin/rails db:prepare     # crea la base, corre las migraciones
bin/rails db:seed        # carga datos de ejemplo (se puede correr más de una vez)
bin/dev                  # o bin/rails server
```

Abrir <http://localhost:3000> (redirige al back-office).

## Credenciales

| Contexto | Email | Contraseña |
|---|---|---|
| Back-office (admin) | `admin@cuentahogar.com` | `admin12345` |
| API (usuario final) | `lucia.martinez@mail.com` | `cuentahogar123` |
| API (usuario final) | `diego.martinez@mail.com` / `sofia.martinez@mail.com` | `cuentahogar123` |

Las credenciales del admin se pueden cambiar al sembrar: `ADMIN_EMAIL=... ADMIN_PASSWORD=... bin/rails db:seed`.

## Calidad y tests

```bash
bin/rails test           # modelos, validaciones, lógica de negocio, mailers, back-office y API
bin/rubocop              # estilo (rubocop-rails-omakase, sin reglas ignoradas)
bin/brakeman --no-pager  # análisis de seguridad
```

## Emails (Action Mailer)

| Email | Cuándo se envía |
|---|---|
| `UserMailer#welcome` | Al registrarse un usuario desde la API (`POST /api/v1/signup`). |
| `ReminderMailer#due_soon` | A cada miembro del hogar cuando un vencimiento está próximo: botón "Avisar por email" del back-office o la tarea `bin/rails reminders:notify` (vencimientos de los próximos 3 días que todavía no se avisaron). |

- Vistas previas: <http://localhost:3000/rails/mailers>
- En desarrollo, sin configuración, los mails se guardan en `tmp/mails/`.
- Para enviarlos de verdad por SMTP (ej. Gmail con contraseña de aplicación):

```bash
export SMTP_ADDRESS=smtp.gmail.com SMTP_PORT=587
export SMTP_USERNAME=tu_cuenta@gmail.com SMTP_PASSWORD=tu_contraseña_de_aplicacion
export MAILER_FROM="CuentaHogar <tu_cuenta@gmail.com>"
bin/rails server
```

## Archivos (Active Storage)

Cada gasto puede tener un **comprobante** (`Expense#receipt`: foto del ticket o factura en JPG, PNG o PDF,
máximo 5 MB). Se adjunta desde el formulario del back-office o desde la API con `multipart/form-data`,
y la API devuelve la URL de descarga en `receipt_url`.

---

## Modelo de datos

```mermaid
erDiagram
    USER ||--o{ SESSION : "inicia (back-office)"
    USER ||--o{ API_TOKEN : "obtiene (API)"
    USER ||--o{ MEMBERSHIP : tiene
    HOUSEHOLD ||--o{ MEMBERSHIP : tiene
    HOUSEHOLD ||--o{ CATEGORY : "define (propias)"
    HOUSEHOLD ||--o{ EXPENSE : registra
    HOUSEHOLD ||--o{ INCOME : registra
    HOUSEHOLD ||--o{ BUDGET : planifica
    HOUSEHOLD ||--o{ REMINDER : agenda
    USER ||--o{ EXPENSE : carga
    USER ||--o{ INCOME : carga
    CATEGORY |o--o{ EXPENSE : clasifica
    CATEGORY |o--o{ BUDGET : limita
```

| Modelo | Descripción | Reglas principales |
|---|---|---|
| **User** | Persona que usa el sistema. `role`: `member` (usuario final, API) o `admin` (back-office). | Nombre obligatorio, email único y con formato válido (se normaliza a minúsculas), contraseña de 8+ caracteres (`has_secure_password`). |
| **Session** | Sesión del back-office (generador de autenticación de Rails 8). | — |
| **ApiToken** | Token del usuario final. Solo se guarda su digest SHA-256; vence a los 30 días. | Digest único, fecha de vencimiento obligatoria. |
| **Household** | Hogar compartido (ej. "Hogar Martínez"). | Nombre obligatorio, moneda ARS o USD. |
| **Membership** | Relación usuario–hogar. `role`: `member` u `owner`. | Un usuario no puede estar dos veces en el mismo hogar. |
| **Category** | Categoría de gasto. Sin hogar = global (para todos). | Nombre único dentro del hogar, color hexadecimal. Al borrarla, sus gastos quedan pendientes de revisión. |
| **Expense** | Gasto. Sin hogar = personal. Sin categoría = pendiente de revisión. `source`: `manual` o `imported` (resumen bancario). Puede ser recurrente y tener comprobante. | Monto > 0, fecha y detalle obligatorios; el usuario debe ser miembro del hogar; la categoría debe ser global o del mismo hogar; comprobante JPG/PNG/PDF ≤ 5 MB. |
| **Income** | Ingreso o aporte de un miembro. | Monto > 0, fecha y detalle obligatorios; el usuario debe ser miembro del hogar. |
| **Budget** | Presupuesto mensual del hogar, general (sin categoría) o por categoría. Calcula gastado, restante, % de uso y si se excedió. | Período = primer día del mes; un solo presupuesto por hogar/categoría/mes; monto > 0. |
| **Reminder** | Vencimiento (tarjeta, servicios, prepaga). Estado: pendiente, vence hoy, vencido o pagado. | Concepto y fecha obligatorios; monto opcional > 0. |

La lógica del "Resumen del mes" (gastos, variación contra el mes anterior, presupuesto, saldo disponible,
pendientes de revisión y gasto por categoría) está en el servicio `MonthlySummary` (`app/services`).
El comportamiento común de gastos e ingresos está en el concern `HouseholdScoped`.

---

## Back-office (`/admin`)

Solo pueden ingresar usuarios con rol `admin`. Incluye:

- **Resumen**: totales del mes, últimos movimientos, próximos vencimientos y estado de cada hogar.
- **ABM completos** de usuarios, hogares (con alta y baja de miembros), categorías, gastos (con comprobante y filtro de pendientes), ingresos, presupuestos y vencimientos (con envío de aviso por email).

## API (`/api/v1`)

Todas las respuestas son JSON. Salvo `signup` y `login`, todos los endpoints requieren el header:

```
Authorization: Bearer <token>
```

Los errores tienen la forma `{ "errors": ["mensaje", ...] }` con status `400`, `401`, `404` o `422`.

### Autenticación

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/signup` | Registro. Body: `{ "user": { "name", "email_address", "password", "password_confirmation" } }`. Envía el email de bienvenida y devuelve un token. |
| POST | `/api/v1/login` | Body: `{ "email_address", "password" }`. Devuelve `{ token, token_type, expires_at, user }`. |
| DELETE | `/api/v1/logout` | Revoca el token actual. |
| GET | `/api/v1/profile` | Datos del usuario y sus hogares. |
| PATCH | `/api/v1/profile` | Body: `{ "user": { "name", "password", "password_confirmation", "password_challenge" } }`. Para cambiar la contraseña hay que enviar la actual en `password_challenge`. |

### Hogares y categorías

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/households` | Hogares del usuario con sus miembros. |
| POST | `/api/v1/households` | Crea un hogar (`{ "household": { "name", "currency" } }`); el creador queda como `owner`. |
| GET | `/api/v1/households/:id` | Detalle de un hogar. |
| GET | `/api/v1/households/:id/summary?month=YYYY-MM` | Resumen del mes (totales, variación, presupuesto, disponible, pendientes, gasto por categoría). |
| GET | `/api/v1/categories?household_id=` | Categorías globales + las de los hogares del usuario. |

### Gastos e ingresos

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/expenses` | Filtros: `household_id`, `scope=personal`, `month=YYYY-MM`, `category_id`, `pending=true`, `limit`. |
| GET | `/api/v1/expenses/:id` | Detalle (incluye `receipt_url`). |
| POST | `/api/v1/expenses` | `{ "expense": { "description", "amount", "spent_on", "household_id", "category_id", "recurring", "notes" } }`. Para adjuntar comprobante enviar `multipart/form-data` con `expense[receipt]`. |
| PATCH | `/api/v1/expenses/:id` | Mismos campos (por ejemplo, asignar categoría a un gasto importado). |
| DELETE | `/api/v1/expenses/:id` | Elimina el gasto. |
| GET / POST / PATCH / DELETE | `/api/v1/incomes[/:id]` | Igual que gastos, con `{ "income": { "description", "amount", "received_on", "household_id" } }`. |

### Planificación

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/budgets?household_id=&month=YYYY-MM` | Presupuestos con `spent`, `remaining`, `usage_percentage` y `exceeded`. |
| POST | `/api/v1/budgets` | `{ "budget": { "household_id", "category_id", "period": "YYYY-MM", "amount" } }`. |
| GET | `/api/v1/reminders` | Filtros: `household_id`, `status=pending|paid|overdue|all`, `days=N` (pendientes de los próximos N días). |
| POST | `/api/v1/reminders` | `{ "reminder": { "household_id", "title", "amount", "due_on" } }`. |
| PATCH | `/api/v1/reminders/:id` | Modifica título, monto o fecha. |
| PATCH | `/api/v1/reminders/:id/pay` | Marca el vencimiento como pagado. |

### Ejemplo rápido con curl

```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email_address":"lucia.martinez@mail.com","password":"cuentahogar123"}' | ruby -rjson -e 'puts JSON.parse(STDIN.read)["token"]')

curl -s http://localhost:3000/api/v1/households -H "Authorization: Bearer $TOKEN"
curl -s "http://localhost:3000/api/v1/expenses?pending=true" -H "Authorization: Bearer $TOKEN"

curl -s -X POST http://localhost:3000/api/v1/expenses -H "Authorization: Bearer $TOKEN" \
  -F "expense[description]=Farmacia" -F "expense[amount]=14780" -F "expense[spent_on]=2026-09-06" \
  -F "expense[household_id]=1" -F "expense[receipt]=@ticket.jpg"
```
