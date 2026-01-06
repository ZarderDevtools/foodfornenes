FoodForNenes App (Flutter)

App móvil en Flutter para gestionar restaurantes, comidas y visitas (FoodForNenes).
El objetivo es mantener una UI limpia, consistente y reutilizable, con componentes genéricos para listados y formularios.

--------------------------------------------------
OBJETIVOS DEL PROYECTO
--------------------------------------------------
- UI clara y bonita, sin sobrecargar.
- Componentes reutilizables (especialmente listados y barras de acción).
- Separar UI de lógica (servicios/repositorios).
- Cambios incrementales y fáciles de mantener.
- Preparado para crecer sin reescribir pantallas.

--------------------------------------------------
EJECUTAR EN LOCAL
--------------------------------------------------
flutter pub get
flutter run

--------------------------------------------------
DECISIONES CLAVE DE UI / UX
--------------------------------------------------

1) LISTADOS (PANTALLA GENÉRICA)
Existe el concepto de ListScreen genérica para reutilizar listados
(Restaurantes, Comidas, etc.), con soporte para:

- Estado vacío:
  Si no hay elementos, mostrar:
  "No existen <nombre_del_listado> actualmente"
  Ejemplo: "No existen restaurantes actualmente"

- Datos nulos:
  - Si no hay rating -> mostrar "--"
  - Si no hay price -> mostrar "" (vacío)

- Acciones del listado:
  - Botones de Filtrar y Ordenar visibles y consistentes
  - Las acciones viven en la barra inferior (no arriba)

- Refresh con gesto:
  - Cuando el usuario está arriba del todo y hace overscroll,
    aparece un indicador (flecha/slide) y al soltar refresca.
  - Debe encajar con los colores y estilo de la app.

--------------------------------------------------

2) BARRA INFERIOR (ACCIONES)

- Barra inferior consistente basada en acciones (BottomAction / BottomBar).
- Máximo 3 posiciones: izquierda, centro, derecha.
- Cada posición puede ser null (si es null no se renderiza).

En formularios:
- Solo deben aparecer Home y Back.
- El botón "+" debe ocultarse.

--------------------------------------------------
FORMULARIOS
--------------------------------------------------

- El mismo formulario sirve para crear y editar.
- Botón principal: Guardar.

Errores del backend:
- Si el backend devuelve errores por campo (DRF típico):
  {
    "name": ["Este campo es requerido."]
  }

- El error debe mostrarse en el campo correspondiente.
- Si llega un error general (detail), se muestra como error global.

--------------------------------------------------
REGLAS DE DESARROLLO
--------------------------------------------------

- No añadir nuevas dependencias sin avisar y justificar.
- Mantener consistencia visual con la app.
- No meter lógica de negocio compleja dentro de widgets.
  - UI en screens / widgets
  - Lógica en services / repositorios

--------------------------------------------------
ESTRUCTURA RECOMENDADA (ORIENTATIVA)
--------------------------------------------------

lib/
- screens/      -> pantallas
- widgets/      -> componentes reutilizables
- models/       -> modelos / DTOs
- services/     -> llamadas a API / repositorios
- config/       -> constantes y helpers

--------------------------------------------------
NOTA SOBRE USO CON IA (CODEX)
--------------------------------------------------

Este proyecto está preparado para trabajar con asistentes de IA.

Reglas:
- Respetar estas decisiones.
- Cambios pequeños y explicados.
- No romper componentes genéricos existentes.
- Mantener compatibilidad al refactorizar.
