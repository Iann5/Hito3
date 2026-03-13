# Documentación del Proyecto: Chatbot Inteligente Multiherramienta

![Vista general del Workflow Completo](./capturas/flujoCompleto.png)

---

## 1. Descripción General

Su objetivo es recibir un mensaje, analizar el mensaje mediante inteligencia artificial y enrutar la petición a la herramienta adecuada para generar una respuesta exacta sobre ese mensaje.

La solución utiliza el siguiente stack tecnológico:
* **Orquestador:** n8n.
* **IA (Clasificación y Extracción):** Ollama (modelo `phi`).
* **Herramientas Externas (APIs):** Open-Meteo, REST Countries, Wikipedia API y JokeAPI.
* **Persistencia de Datos:** PostgreSQL.

---

## 2. Análisis Paso a Paso del Workflow

El flujo se compone de una estructura condicional que procesa la información de forma dinámica basándose en la decisión de la IA:

### A. Inicialización y Disparo del Flujo (Webhook)

![Captura del nodo Webhook](./capturas/configWebhook.png)
*Configuración del Webhook de entrada.*

* **Función:** Actúa como el punto de entrada del sistema.
* **Configuración:** Está configurado para escuchar peticiones HTTP POST en la ruta `chat`.
* **Entrada:** Recibe un cuerpo JSON con el mensaje del usuario (ejemplo: `{"mensaje": "cuéntame un chiste"}`).

### B. Análisis de Intención (Ollama)

![Captura del nodo Ollama Analiza Intención](./capturas/prompt.png)
*Prompt*

Una vez que el mensaje entra por el Webhook, el nodo **Ollama Analiza Intención** toma el control. Este nodo actúa como el cerebro clasificador del sistema.

* **Configuración:** Realiza una petición POST a la API local de Ollama utilizando el modelo `phi`.
* **Prompt Engineering:** Se construye un prompt estricto (System Prompt) con `temperature: 0` que obliga a la IA a leer el mensaje del usuario y responder exclusivamente con una de las siguientes palabras clave: `clima`, `pais`, `wiki` o `chiste`.

### C. Enrutamiento Dinámico (Switch Herramientas)

![Captura del nodo Switch](./capturas/switchR1.png)
![Captura del nodo Switch](./capturas/switchR2.png)
*Reglas de enrutamiento basadas en la respuesta de la IA.*

* **Función:** Enruta el flujo de ejecución hacia la API correspondiente.
* **Proceso:** Toma el valor devuelto por Ollama en el paso anterior, lo normaliza (minúsculas) y evalúa las reglas. Dependiendo de la intención, se ejecuta una de las cuatro ramas.

### D. Ejecución de Herramientas (APIs Externas)

Dependiendo de la salida del nodo Switch, el flujo toma uno de estos caminos específicos:

1. **Ruta Clima:**
   * **Extracción:** Un nodo de Ollama extrae únicamente el nombre de la ciudad del mensaje original.
   * **Procesamiento:** Se ejecutan dos peticiones HTTP consecutivas; la primera (Open-Meteo Geocoding) obtiene las coordenadas de la ciudad, y la segunda (Open-Meteo Forecast) recupera la temperatura actual.
2. **Ruta País:**
   * **Extracción:** Ollama aísla el nombre del país.
   * **Procesamiento:** Se realiza una petición a REST Countries para extraer la capital y el número de habitantes.
3. **Ruta Wikipedia:**
   * **Extracción:** Ollama identifica el tema principal de búsqueda.
   * **Procesamiento:** Una petición HTTP a la API de Wikipedia devuelve un resumen de exactamente 3 frases sobre el tema.
4. **Ruta Chiste:**
   * **Procesamiento:** Llama directamente a JokeAPI para obtener un chiste aleatorio en español.

### E. Persistencia de Metadatos (PostgreSQL)

![Captura de los nodos de Postgres](./capturas/configDatosPostgres.png)
*Configuración de la inserción de datos en PostgreSQL.*


* **Operación:** Se inserta una fila en la tabla `historial_chat` para llevar un control de trazabilidad.
* **Datos registrados:** Independientemente de la rama ejecutada, se guarda el `mensaje_usuario`, la `intencion_detectada`, la `herramienta_usada` (ej. Wikipedia API, OpenMeteo) y la `respuesta_bot` generada.

### F. Respuesta al Usuario (Respond to Webhook)

![Captura del nodo Respond to Webhook](./capturas/respuestaWebhook.png)
*Respuesta del webhook.*

* **Función:** Cierra el ciclo de comunicación devolviendo la respuesta final al cliente que realizó la consulta.
* **Salida:** Devuelve el texto procesado y formateado con los datos obtenidos de la API correspondiente, entregándolo directamente como respuesta a la petición POST inicial.