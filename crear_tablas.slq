-- Esquema de base de datos para RugbyStats
-- Archivo: crear_tablas.slq
PRAGMA foreign_keys = ON;

-- Borrar tablas antiguas que pude haber creado
DROP TABLE IF EXISTS competitions;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS events;

-- Tablas según diagrama (nombres en español)

-- Tabla de tipos de acción (lista de tipos como filas)
CREATE TABLE IF NOT EXISTS Tipo_Accion (
    Id_Tipo_Accion INTEGER PRIMARY KEY AUTOINCREMENT,
    Nombre TEXT NOT NULL UNIQUE
);

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS Usuario (
    IdUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
    Nombre_Usuario TEXT NOT NULL,
    Contrasena TEXT,
    Email TEXT,
    Telefono TEXT
);

-- Tabla de partidos
CREATE TABLE IF NOT EXISTS PARTIDO (
    Id_Partido INTEGER PRIMARY KEY AUTOINCREMENT,
    Fecha TEXT,
    Equipo_Visitante TEXT,
    Equipo_local TEXT,
    Estado_partido TEXT,
    Torneo TEXT,
    Puntos INTEGER DEFAULT 0,
    Division TEXT,
    Id_Usuario INTEGER REFERENCES Usuario(IdUsuario) ON DELETE SET NULL
);

-- Tabla de acción (evento registrado en un partido)
CREATE TABLE IF NOT EXISTS Accion (
    IdAccion INTEGER PRIMARY KEY AUTOINCREMENT,
    Resultado_Accion TEXT,
    Id_Tipo_Accion INTEGER REFERENCES Tipo_Accion(Id_Tipo_Accion) ON DELETE SET NULL,
    Tiempo_Accion TEXT,
    Orden_Accion INTEGER,
    Equipo_Accion TEXT,
    Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
);

-- Tabla de reportes relacionados a un partido
CREATE TABLE IF NOT EXISTS REPORTE (
    ID_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
    Contenido_Reporte TEXT,
    Fecha_Generacion TEXT,
    Nombre TEXT,
    Tipo_Reporte TEXT,
    Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_accion_partido ON Accion(Id_Partido);
CREATE INDEX IF NOT EXISTS idx_reporte_partido ON REPORTE(Id_Partido);
CREATE INDEX IF NOT EXISTS idx_partido_usuario ON PARTIDO(Id_Usuario);

-- Población inicial de tipos de acción (según lista del diagrama)
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Try');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Patada');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Scrum');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Maul');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Line');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Salida');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Tackle');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Penal');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Error_No_Forzado');
INSERT OR IGNORE INTO Tipo_Accion(Nombre) VALUES ('Tarjeta');


