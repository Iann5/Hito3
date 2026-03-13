-- Tabla 1: Documentos procesados (Proyecto A)
CREATE TABLE documentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ruta_archivo TEXT,
    num_chunks INTEGER,
    fecha_procesado TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_documentos_nombre ON documentos(nombre);

-- Tabla 2: Historial de consultas RAG (Proyecto A)
CREATE TABLE consultas_rag (
    id SERIAL PRIMARY KEY,
    pregunta TEXT NOT NULL,
    respuesta TEXT NOT NULL,
    documentos_usados TEXT[],
    timestamp TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_consultas_timestamp ON consultas_rag(timestamp DESC);

-- Tabla 3: Historial del Chatbot (Proyecto B)
CREATE TABLE IF NOT EXISTS historial_chat (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensaje_usuario TEXT NOT NULL,
    intencion_detectada VARCHAR(50),
    herramienta_usada VARCHAR(50),
    respuesta_bot TEXT NOT NULL
);