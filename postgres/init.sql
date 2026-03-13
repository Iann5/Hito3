-- Tabla 3: Historial del Chatbot (Proyecto B)
CREATE TABLE IF NOT EXISTS historial_chat (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensaje_usuario TEXT NOT NULL,
    intencion_detectada VARCHAR(50),
    herramienta_usada VARCHAR(50),
    respuesta_bot TEXT NOT NULL
);