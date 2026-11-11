# Casvium · Gestión Artesanal de Tareas Domésticas (Flutter + Railway PostgreSQL)

Aplicación Flutter con diseño **Neo-Bento Artesanal** (sin aspecto genérico de Material Design), mascota animada (**Don Mocho**, una fregona humanizada), **30 iconos vectoriales propios**, infografías interactivas y persistencia en **PostgreSQL alojado en Railway**.

## Características principales

1. **Hogares, Miembros y Estancias**:
   - Creación de hogares con código de invitación y uno o varios miembros con roles y colores propios.
   - Estancias por defecto (*Cocina, Baño Principal, Salón-Comedor, Dormitorio, Lavadero y Colada, Terraza y Plantas, Recibidor*) y creación de nuevas estancias.
2. **Tareas Domésticas Multi-Estancia y Compartidas**:
   - Cada tarea puede asociarse a **una o varias estancias**, definir su **duración estimada** mediante un selector táctil personalizado, y marcarse como **compartida** o individual.
   - Incluye 9 tareas frecuentes precargadas listas para usar.
3. **30 Iconos Vectoriales Personalizados (`CustomPainter`)**:
   - Catálogo propio de 30 ilustraciones vectoriales para tareas típicas en `lib/data/chore_icons.dart`.
4. **Registro de Sesiones de Trabajo y Cronómetro en Vivo**:
   - Registra fecha, miembro ejecutor, colaboradores, usuario que registra la sesión, tarea, estancia, duración real y notas.
5. **Infografías, Gráficas y Mascota Animada**:
   - **Don Mocho** (`lib/widgets/fregona_mascot.dart`): Fregona humanizada animada con flecos dinámicos, parpadeo, burbujas de jabón y estados (`happy`, `scrubbing`, `celebrating`).
   - **Gráficas propias** (`lib/widgets/custom_charts.dart`): Anillo de equidad entre miembros, curva semanal de pulso doméstico y mapa de dedicación por estancia.
6. **PostgreSQL en Railway**:
   - Esquema SQL completo en `sql/railway_schema.sql` y sincronización directa desde la pestaña **Railway DB** introduciendo el `DATABASE_URL` (`postgresql://...`) de tu instancia en Railway.

## Ejecución

```bash
flutter create .
flutter pub get
flutter run
```
