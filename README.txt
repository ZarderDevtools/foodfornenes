README – FoodForNenes App (Flutter)
=================================

Descripción
-----------
Aplicación móvil desarrollada en Flutter para el proyecto FoodForNenes.
Permite gestionar entidades como restaurantes, comidas y visitas, priorizando
una experiencia de usuario clara, consistente y fácil de mantener.

El proyecto está diseñado para crecer de forma ordenada, usando componentes
reutilizables y decisiones de UI/UX bien definidas.


Objetivos del proyecto
----------------------
- Interfaz limpia y agradable, sin sobrecargar al usuario.
- Reutilización de componentes (listados, formularios, barras de acciones).
- Separación clara entre UI y lógica de negocio.
- Cambios incrementales y controlados.
- Código fácil de entender y mantener a largo plazo.


Ejecución en local
------------------
Requisitos:
- Flutter SDK instalado
- Emulador, dispositivo físico o navegador (web)

Comandos básicos:
flutter pub get
flutter run


Decisiones clave de UI / UX
---------------------------

1) Listados (pantalla genérica)
- Se utiliza una pantalla genérica de listado para diferentes entidades.
- Comportamientos definidos:
  - Estado vacío:
    Mostrar el mensaje:
    "No existen <nombre_del_listado> actualmente"
    Ejemplo: "No existen restaurantes actualmente"

  - Valores nulos:
    - Rating nulo → mostrar "--"
    - Price nulo → mostrar string vacío ""

  - Acciones:
    - Botones de Filtrar y Ordenar visibles y consistentes
    - Las acciones se sitúan en la barra inferior

  - Refresco:
    - Al hacer overscroll en la parte superior, aparece un indicador
      (flecha/slide) y al soltar se refresca el listado
    - El indicador debe respetar los colores y estilo de la app


2) Barra inferior de acciones
- Uso de una barra inferior común basada en acciones.
- Máximo de 3 posiciones: izquierda, centro y derecha.
- Cada posición puede ser null (si es null no se renderiza).

En formularios:
- Solo deben mostrarse las acciones Home y Back.
- El botón “+” debe ocultarse.


3) Formularios
- Un mismo formulario sirve para crear y editar.
- Botón principal siempre: Guardar.

Errores de backend:
- Si el backend devuelve errores por campo (estructura típica de DRF),
  el error se muestra asociado al campo correspondiente.
- Si llega un error general (por ejemplo, “detail”), se muestra como error global.


Reglas de desarrollo
--------------------
- No añadir nuevas dependencias sin avisar y justificar.
- Mantener consistencia visual en toda la app.
- Evitar lógica de negocio compleja dentro de widgets:
  - UI en screens / widgets
  - Lógica en services / repositorios


Estructura recomendada del proyecto
-----------------------------------
lib/
- screens/    -> pantallas
- widgets/    -> componentes reutilizables
- models/     -> modelos / DTOs
- services/   -> llamadas a API y repositorios
- config/     -> constantes, helpers y configuración


Uso con asistentes de IA (Codex)
--------------------------------
Este repositorio está preparado para trabajar con asistentes de IA.

Reglas básicas:
- Respetar las decisiones descritas en este README.
- Cambios pequeños y bien explicados.
- No romper componentes genéricos existentes.
- Mantener compatibilidad al refactorizar.


Notas finales
-------------
Este README define el marco general del proyecto.
Las decisiones estables de arquitectura y UI/UX se detallan en el documento
de decisiones del proyecto (docs/decisions.md).
