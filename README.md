# Measures of populations sizes from Ebird data

El propósito principal de este repositorio es construir un flujo de trabajo simple y entendible en R para calcular tamaños poblacionales en escalas pequeñas a partir de datos de especies en los modelos de abundancia construidos en Ebird.

*The main purpose of this repository is to build a simple and understandable workflow in R to caculate populations sizes at small scales from species Ebird Trends and Stats Models.*

El flujo de trabajo puede ser resumido de la siguiente manera:

1. Descarga de los modelos de Ebird con el paquete ebirdst para cada especie
2. Selección de datos de interés (e.g. abundancia, occurrencia)
3. Selección de la época del año para los análisis (semanas específicas en caso de especies migratorias)
4. Calculo de medidas en la temporada seleccionada
5. Corte de capas y calculo de valores según la escala (área de interes vs valores a nivel nacional, departamental, etc)

