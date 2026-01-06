DECISIONES DEL PROYECTO (FoodForNenes - Flutter)
Documento para humanos + Codex
=================================================

Propósito
---------
Este documento recoge las decisiones estables (arquitectura + UI/UX) que deben
mantenerse en el proyecto para garantizar consistencia, mantenibilidad y una
experiencia de usuario coherente.

Se usa como “contrato”:
- Para desarrollo humano: evita rehacer debates ya cerrados.
- Para IA (Codex): guía de comportamiento para no romper componentes ni estilo.

Si alguna decisión cambia, se actualiza aquí primero y luego se aplica al código.


1) Principios generales
----------------------
1.1 Claridad > “magia”
- Priorizamos soluciones claras, simples y predecibles.
- Evitar abstracciones innecesarias que hagan difícil entender el flujo.

1.2 Reutilización
- Preferimos componentes genéricos (ListScreen, barras, scaffolds de formulario)
  en lugar de pantallas duplicadas.

1.3 Separación de responsabilidades
- UI en pantallas/widgets.
- Lógica (API, repositorios, parseos, validaciones) fuera de la UI.
- No “mezclar” llamadas HTTP dentro de widgets.

1.4 Cambios incrementales
- Cambios pequeños y controlados.
- Mantener compatibilidad cuando se refactoriza un componente genérico.


2) Decisiones de UI / UX
------------------------

2.1 Listados (ListScreen genérica)
- Debe existir una pantalla genérica de listados reutilizable para entidades
  como Restaurantes, Comidas, etc.
- Debe soportar:
  a) Estado vacío:
     - Mostrar un mensaje claro:
       "No existen <nombre_del_listado> actualmente"
       Ejemplo: "No existen restaurantes actualmente"
  b) Datos nulos / faltantes:
     - Rating nulo -> mostrar "--"
     - Price nulo -> mostrar string vacío ""
  c) Acciones del listado:
     - Botones de "Filtrar" y "Ordenar" accesibles de forma consistente.
     - Estas acciones van en la barra inferior (no arriba ni flotantes).
  d) Refresh con gesto (overscroll en top):
     - Cuando el usuario está arriba del todo y hace overscroll, aparece un
       indicador (flecha/slide) y al soltar refresca el listado.
     - Debe integrarse con el estilo y colores de la app.

2.2 Formularios (crear / editar)
- Un mismo formulario debe servir para:
  - Crear
  - Editar
- Botón principal: "Guardar"
- Barra inferior en formularios:
  - Solo Home y Back
  - El botón "+" no debe aparecer

2.3 Errores de validación (backend)
- Se prioriza mostrar errores por campo cuando el backend los devuelve con la
  estructura típica de DRF:
  {
    "field": ["mensaje"]
  }
- El error debe mostrarse asociado al campo correspondiente.
- Si el backend devuelve un error general (por ejemplo "detail"), se mostrará
  como error global.

2.4 Consistencia visual
- Mantener coherencia con paleta/estilo ya existente.
- Evitar introducir nuevos estilos “random” por pantalla.
- Animaciones/indicadores (ej. refresh) deben encajar con el look & feel.


3) Componentes clave (no romper)
--------------------------------
Estos componentes son “pilares” del proyecto. Si se modifican, debe mantenerse
compatibilidad o refactorizar de forma segura:

- ListScreen<T>
  - Responsable de: renderizar listados, gestionar estados (cargando/vacío/error),
    paginación si aplica, y disparar acciones (ordenar/filtrar/refrescar).
- BottomAction / BottomBar
  - Responsable de: presentar acciones consistentes en barra inferior.
  - Restricción: máximo 3 posiciones (izq/centro/dcha).
  - Cada posición puede ser null (si es null no se renderiza).
- (Si existe) FormScaffold / FormScreen base
  - Responsable de: estructura consistente de formularios, botón Guardar,
    manejo de errores por campo, y barra inferior coherente.

Regla: antes de cambiar un componente clave, describir:
- Qué cambia
- Por qué
- Cómo se prueba
- Qué compatibilidad mantiene


4) Organización del código (estructura)
---------------------------------------
Estructura orientativa (puede evolucionar, pero manteniendo la idea):

lib/
- screens/   -> pantallas (UI + orquestación ligera)
- widgets/   -> componentes reutilizables (UI pura)
- models/    -> modelos/DTOs (mapeo de respuestas y estructuras)
- services/  -> llamadas HTTP/repositorios/casos de uso
- config/    -> constantes, endpoints, helpers, configuración

Reglas:
- Evitar “god files” gigantes.
- Preferir nombres explícitos a abreviaturas.
- Mantener funciones pequeñas y testeables donde sea posible.


5) Dependencias (paquetes)
--------------------------
- No añadir nuevas dependencias sin:
  1) Proponerlo explícitamente
  2) Justificar por qué no se resuelve con lo existente
  3) Indicar impacto (tamaño, mantenimiento, compatibilidad)

Regla práctica:
- Si la dependencia solo “ahorra 20 líneas”, normalmente NO se añade.
- Si resuelve un problema real (formularios complejos, auth, http robusto),
  entonces se evalúa.


6) Reglas para trabajar con IA (Codex)
--------------------------------------
Codex debe comportarse así:

6.1 Antes de tocar código
- Indicar qué ficheros va a modificar.
- Explicar el enfoque en 3-5 bullets, sin extenderse.

6.2 Al modificar
- Cambios pequeños e incrementales.
- Mantener compatibilidad con componentes genéricos.
- Respetar decisiones de UI/UX y estilo.

6.3 Después de modificar
- Resumen de lo cambiado.
- Pasos concretos de prueba (cómo verificar).

6.4 Restricciones
- No añadir dependencias sin proponerlo primero.
- No cambiar la arquitectura sin avisar.
- No “redecorar” la app (colores/estilos) sin necesidad.


7) Cómo actualizar este documento
---------------------------------
- Si surge una decisión nueva “estable”, se añade aquí.
- Si una decisión cambia:
  1) Se actualiza aquí primero
  2) Luego se aplica al código
  3) Se valida que no rompe pantallas existentes

Fin.
