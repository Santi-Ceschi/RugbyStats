CREATE TABLE Tipo_Accion (
	Id_Tipo_Accion INTEGER PRIMARY KEY AUTOINCREMENT,
	Nombre TEXT NOT NULL UNIQUE
);
CREATE TABLE Usuario (
	IdUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
	Nombre_Usuario TEXT NOT NULL,
	Contrasena TEXT,
	Email TEXT UNIQUE,
	Telefono TEXT
);
CREATE TABLE PARTIDO (
	Id_Partido INTEGER PRIMARY KEY AUTOINCREMENT,
	Fecha DATE NOT NULL,
	Equipo_Visitante TEXT,
	Equipo_local TEXT,
	Estado_partido TEXT,
	Torneo TEXT,
	Puntos_local INTEGER DEFAULT 0,
	Puntos_visitante INTEGER DEFAULT 0,
	Division TEXT,
	Hora_Inicio TEXT,
	Minutos_Ajuste INTEGER DEFAULT 0,
	Somos_Local INTEGER DEFAULT 1,
	Id_Usuario INTEGER NOT NULL REFERENCES Usuario(IdUsuario) ON DELETE RESTRICT
);
CREATE TABLE Accion (
	IdAccion INTEGER PRIMARY KEY AUTOINCREMENT,
	Resultado_Accion TEXT,
	Id_Tipo_Accion INTEGER REFERENCES Tipo_Accion(Id_Tipo_Accion) ON DELETE SET NULL,
	Tiempo_Accion TEXT,
	Orden_Accion INTEGER,
	Equipo_Accion TEXT,
	Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
);
CREATE TABLE REPORTE (
	ID_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
	Contenido_Reporte TEXT,
	Fecha_Generacion DATETIME NOT NULL,
	Nombre TEXT,
	Tipo_Reporte TEXT,
	Id_Partido INTEGER REFERENCES PARTIDO(Id_Partido) ON DELETE CASCADE
);
CREATE INDEX idx_accion_partido ON Accion(Id_Partido);
CREATE INDEX idx_reporte_partido ON REPORTE(Id_Partido);
CREATE INDEX idx_partido_usuario ON PARTIDO(Id_Usuario);

