##Videojuego Adaptativo con Machine Learning (DDA)

Proyecto de investigación y desarrollo enfocado en la implementación de un videojuego 2D adaptativo, capaz de modificar la dificultad y el comportamiento de los NPCs en tiempo real según el desempeño del jugador, utilizando Godot Engine y técnicas de Machine Learning.

##Descripción del proyecto

Este proyecto implementa un prototipo funcional de videojuego desarrollado en Godot 4.4, en el cual se integran algoritmos de aprendizaje automático para analizar el comportamiento del jugador y ajustar automáticamente la dificultad del juego.

El sistema recopila métricas durante la partida y utiliza modelos de ML para:

Analizar el estilo de juego.
Clasificar al jugador.
Ajustar dificultad.
Modificar comportamiento de enemigos.
Personalizar la experiencia.
##Objetivo general

Desarrollar un videojuego que adapte la dificultad y el comportamiento de los personajes no jugables en función del desempeño del jugador, mediante un motor de videojuegos y técnicas de Machine Learning.

##Objetivos específicos
OE1 — Definir concepto del videojuego
Diseño del videojuego.
Mecánicas principales.
Personajes.
Sistema adaptativo.
Métricas del jugador.
Técnicas ML seleccionadas.
OE2 — Planificación técnica
Arquitectura del sistema.
Diseño modular.
Scripts y nodos.
Componentes Godot.
Integración ML.
Fichas técnicas.
Iteraciones de desarrollo.
OE3 — Implementación
Desarrollo del prototipo.
Captura de métricas.
Modelos ML.
Adaptación dinámica.
Versiones iterativas.
Ajuste de NPCs.
Validación funcional.
OE4 — Validación beta
Pruebas con usuarios.
Encuestas.
Corrección de errores.
Verificación del sistema adaptativo.
Consistencia de adaptación.
## Tecnologías utilizadas
Motor de desarrollo
Godot Engine 4.4
Lenguaje
GDScript
Machine Learning

Implementación simulada/integrada de:

Regresión lineal
Árbol de decisión
Clustering (K-Means simplificado)
Control de versiones
Git
GitHub
## Mecánicas implementadas

El videojuego incluye:

* Movimiento del jugador
* Ataque cuerpo a cuerpo
* Recolección de recursos
* Construcción
* Sistema de enemigos
* NPCs adaptativos
* Sistema de vida
* Inventario
* Herramientas
* Defensa
* Progresión
* Métricas automáticas
* IA adaptativa
* Generación procedural básica

## Métricas capturadas

El sistema registra automáticamente:

Tiempo de supervivencia
Enemigos derrotados
Daño recibido
Recursos recolectados
Nivel alcanzado
Tiempo entre combates

Archivos generados en:

user://metrics/

Formato:

.json
## Machine Learning implementado

Los modelos se encuentran en:

Scripts/MachineLearning/
Modelos:
Regresión lineal

Calcula nivel de dificultad.

Árbol de decisión

Clasifica el tipo de jugador.

Clustering

Agrupa comportamientos similares.

🤖 Adaptación de NPCs

Los enemigos ajustan:

Velocidad
Vida
Daño
Frecuencia de ataque
Patrón de comportamiento
## Estructura del repositorio
tesis-videojuego-ml/
│
├── Juego/
├── Scripts/
│   ├── Player/
│   ├── Enemies/
│   ├── MachineLearning/
│   └── Systems/
│
├── Assets/
├── Scenes/
├── Dataset/
├── Metrics/
├── Builds/
├── Versions/
└── README.md
## Cómo ejecutar el proyecto
Opción 1 — Abrir proyecto en Godot
Descargar repositorio.
Abrir Godot 4.4.
Importar carpeta:
Juego/
Ejecutar con:
F5
## Controles del juego
Acción	Tecla
Movimiento	W A S D
Atacar	Z
Espada	1
Hacha	2
Pico	3
Saltar	Espacio
Construir	5
## Versiones del proyecto

El desarrollo fue iterativo:

Versiones principales
v0.1 Prototipo inicial
v0.2 Sistema de combate
v0.3 Recolección de métricas
v0.4 Machine Learning
v0.5 Adaptación dinámica
v0.6 Optimización
v1.0 Beta final
## Resultados obtenidos
Implementación

✔ Prototipo funcional
✔ Sistema adaptativo
✔ Integración ML
✔ Captura automática
✔ Ajuste de NPCs
✔ Validación beta

Resultados beta
12 usuarios evaluados
20+ sesiones
91.7% percibieron adaptación
82% consistencia adaptativa
<5% errores críticos
## Evidencias
Video demostrativo

Repositorio:

Software en funcionamiento - Videojuego DDA

Video:

YouTube demostración

## Documentación

Incluye:

Fichas técnicas
Diagramas
Versiones
Encuestas
JSON de métricas
Resultados beta
Capturas
Evidencias
## Autor

Andrés Felipe Ordóñez Carrasco

Proyecto de grado
Ingeniería de Sistemas
2026

## Investigación asociada

Trabajo de investigación enfocado en:

Dynamic Difficulty Adjustment (DDA)
Player Modeling
Game AI
Machine Learning aplicado a videojuegos
Adaptive NPC Behavior
## Estado del proyecto

