# CuentaHogar — Back-end (TP N° 1, Programación IV, UTN FRLP)

App de control de gastos personal y del hogar. Ruby on Rails 8, con un back-office web
y una API JSON versionada que después va a consumir un front-end.

El código base viene de un overlay ya escrito en `C:\Users\nico_\OneDrive\Escritorio\prog4\cuenta_hogar_tp1`
(modelos, migraciones, controladores, vistas, mailers, seeds y tests). Se copia por
partes, en el orden que indique el usuario, revisando y commiteando cada parte.

## Reglas de trabajo

- Trabajar solo el paso pedido. No adelantarse a los siguientes.
- No agregar gems que no estén en el Gemfile por defecto de Rails 8, salvo pedido explícito.
- Después de copiar archivos, correr lo necesario para verificar que funcionan
  (migraciones, tests, levantar el server) y mostrar el resultado real, sin suponerlo.
- Si algo falla, mostrar el error completo y proponer el arreglo antes de aplicarlo.
- Mensajes de commit en español, en imperativo y en una línea
  (ej.: "Agregar modelos y migraciones del dominio").
- No hacer push ni crear ramas salvo pedido explícito.

## Requisitos obligatorios del TP

1. Rails + Git con commits que reflejen la evolución.
2. Mínimo 5 modelos relacionados, con validaciones.
3. Back-office en namespace `admin` con CRUD protegido por autenticación.
4. API JSON versionada en `/api/v1`, separada del back-office.
5. Dos contextos de usuario: admin (autenticación nativa de Rails) y usuario final
   (login contra la API, que devuelve un token).
6. Active Storage con un caso de uso real.
7. Action Mailer con al menos un envío real.
8. Tests de modelos, validaciones y lógica de negocio.
9. Rubocop pasando.
10. Brakeman pasando.

Además: un README que permita clonar y ejecutar el proyecto sin conocimiento previo.
