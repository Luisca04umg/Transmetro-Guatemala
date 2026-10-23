/*=============================================================================
  PROYECTO: Sistema Web de Control y Gestion de Transmetro
  MOTOR:    Microsoft SQL Server 2022/2025 y Azure SQL Database
  AUTOR:    Luis Carlos Barrera Ramirez
  OBJETIVO: Crear las estructuras, reglas, procedimientos y reportes requeridos.

  EJECUCION:
    1. Abrir SQL Server Management Studio o Azure Data Studio.
    2. Ejecutar el script con una cuenta autorizada para crear bases de datos.
    3. En Azure SQL Database, crear previamente la base de datos y ejecutar desde
       la seccion "USE TransmetroGestionDB" (omitir CREATE DATABASE y USE master).

  SEGURIDAD:
    - No se almacenan contrasenas en texto plano.
    - ContrasenaHash y ContrasenaSalt deben generarse en ASP.NET Core.
    - La aplicacion debe usar consultas parametrizadas/Entity Framework Core.
    - Antes de cada transaccion, la aplicacion puede registrar el usuario con:
      EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID', @value=1;
=============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE master;
GO

IF DB_ID(N'TransmetroGestionDB') IS NULL
BEGIN
    CREATE DATABASE TransmetroGestionDB;
END;
GO

USE TransmetroGestionDB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*=============================================================================
  1. ESQUEMAS
=============================================================================*/
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'cat') EXEC(N'CREATE SCHEMA cat');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'ops') EXEC(N'CREATE SCHEMA ops');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'seg') EXEC(N'CREATE SCHEMA seg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'fin') EXEC(N'CREATE SCHEMA fin');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'aud') EXEC(N'CREATE SCHEMA aud');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'rep') EXEC(N'CREATE SCHEMA rep');
GO

/*=============================================================================
  2. CATALOGOS, MUNICIPALIDADES Y ESTRUCTURA DE LINEAS/ESTACIONES
=============================================================================*/
CREATE TABLE cat.Municipalidad
(
    MunicipalidadID INT IDENTITY(1,1) NOT NULL,
    Codigo           VARCHAR(20)       NOT NULL,
    Nombre           NVARCHAR(150)     NOT NULL,
    Departamento     NVARCHAR(100)     NOT NULL CONSTRAINT DF_Municipalidad_Dep DEFAULT N'Guatemala',
    Telefono         VARCHAR(25)       NULL,
    Correo           VARCHAR(254)      NULL,
    Direccion        NVARCHAR(300)     NULL,
    Activa           BIT               NOT NULL CONSTRAINT DF_Municipalidad_Activa DEFAULT (1),
    FechaCreacion    DATETIME2(0)      NOT NULL CONSTRAINT DF_Municipalidad_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila      ROWVERSION        NOT NULL,
    CONSTRAINT PK_Municipalidad PRIMARY KEY (MunicipalidadID),
    CONSTRAINT UQ_Municipalidad_Codigo UNIQUE (Codigo),
    CONSTRAINT UQ_Municipalidad_Nombre UNIQUE (Nombre),
    CONSTRAINT CK_Municipalidad_Correo CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')
);
GO

CREATE TABLE ops.Linea
(
    LineaID           INT IDENTITY(1,1) NOT NULL,
    MunicipalidadID  INT               NOT NULL,
    Codigo            VARCHAR(20)       NOT NULL,
    Nombre            NVARCHAR(150)     NOT NULL,
    Descripcion       NVARCHAR(500)     NULL,
    Estado            CHAR(1)           NOT NULL CONSTRAINT DF_Linea_Estado DEFAULT ('P'),
    FechaCreacion     DATETIME2(0)      NOT NULL CONSTRAINT DF_Linea_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila       ROWVERSION        NOT NULL,
    CONSTRAINT PK_Linea PRIMARY KEY (LineaID),
    CONSTRAINT FK_Linea_Municipalidad FOREIGN KEY (MunicipalidadID)
        REFERENCES cat.Municipalidad(MunicipalidadID),
    CONSTRAINT UQ_Linea_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Linea_Estado CHECK (Estado IN ('P','A','I'))
);
GO

CREATE TABLE ops.Estacion
(
    EstacionID          INT IDENTITY(1,1) NOT NULL,
    MunicipalidadID    INT               NOT NULL,
    Codigo              VARCHAR(20)       NOT NULL,
    Nombre              NVARCHAR(150)     NOT NULL,
    Direccion           NVARCHAR(300)     NULL,
    Latitud             DECIMAL(9,6)      NULL,
    Longitud            DECIMAL(9,6)      NULL,
    CapacidadReferencia SMALLINT          NOT NULL CONSTRAINT DF_Estacion_Capacidad DEFAULT (80),
    Estado              CHAR(1)           NOT NULL CONSTRAINT DF_Estacion_Estado DEFAULT ('P'),
    FechaCreacion       DATETIME2(0)      NOT NULL CONSTRAINT DF_Estacion_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila         ROWVERSION        NOT NULL,
    CONSTRAINT PK_Estacion PRIMARY KEY (EstacionID),
    CONSTRAINT FK_Estacion_Municipalidad FOREIGN KEY (MunicipalidadID)
        REFERENCES cat.Municipalidad(MunicipalidadID),
    CONSTRAINT UQ_Estacion_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Estacion_Capacidad CHECK (CapacidadReferencia > 0),
    CONSTRAINT CK_Estacion_Estado CHECK (Estado IN ('P','A','I')),
    CONSTRAINT CK_Estacion_Latitud CHECK (Latitud IS NULL OR Latitud BETWEEN -90 AND 90),
    CONSTRAINT CK_Estacion_Longitud CHECK (Longitud IS NULL OR Longitud BETWEEN -180 AND 180)
);
GO

CREATE TABLE ops.LineaEstacion
(
    LineaID      INT          NOT NULL,
    EstacionID   INT          NOT NULL,
    Orden        SMALLINT     NOT NULL,
    TiempoMinuto SMALLINT     NULL,
    FechaAlta    DATETIME2(0) NOT NULL CONSTRAINT DF_LineaEstacion_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_LineaEstacion PRIMARY KEY (LineaID, EstacionID),
    CONSTRAINT FK_LineaEstacion_Linea FOREIGN KEY (LineaID)
        REFERENCES ops.Linea(LineaID),
    CONSTRAINT FK_LineaEstacion_Estacion FOREIGN KEY (EstacionID)
        REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT UQ_LineaEstacion_Orden UNIQUE (LineaID, Orden),
    CONSTRAINT CK_LineaEstacion_Orden CHECK (Orden > 0),
    CONSTRAINT CK_LineaEstacion_Tiempo CHECK (TiempoMinuto IS NULL OR TiempoMinuto >= 0)
);
GO

CREATE TABLE ops.TramoLinea
(
    TramoID            BIGINT IDENTITY(1,1) NOT NULL,
    LineaID            INT                 NOT NULL,
    EstacionOrigenID   INT                 NOT NULL,
    EstacionDestinoID  INT                 NOT NULL,
    DistanciaKm        DECIMAL(9,3)        NOT NULL,
    FechaActualizacion DATETIME2(0)        NOT NULL CONSTRAINT DF_Tramo_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_TramoLinea PRIMARY KEY (TramoID),
    CONSTRAINT FK_Tramo_Origen FOREIGN KEY (LineaID, EstacionOrigenID)
        REFERENCES ops.LineaEstacion(LineaID, EstacionID),
    CONSTRAINT FK_Tramo_Destino FOREIGN KEY (LineaID, EstacionDestinoID)
        REFERENCES ops.LineaEstacion(LineaID, EstacionID),
    CONSTRAINT UQ_Tramo_Origen UNIQUE (LineaID, EstacionOrigenID),
    CONSTRAINT UQ_Tramo_Destino UNIQUE (LineaID, EstacionDestinoID),
    CONSTRAINT CK_Tramo_Estaciones CHECK (EstacionOrigenID <> EstacionDestinoID),
    CONSTRAINT CK_Tramo_Distancia CHECK (DistanciaKm > 0)
);
GO

CREATE TABLE ops.Acceso
(
    AccesoID       INT IDENTITY(1,1) NOT NULL,
    EstacionID     INT               NOT NULL,
    Codigo         VARCHAR(30)       NOT NULL,
    Nombre         NVARCHAR(120)     NOT NULL,
    Descripcion    NVARCHAR(300)     NULL,
    TipoAcceso     VARCHAR(20)       NOT NULL CONSTRAINT DF_Acceso_Tipo DEFAULT ('PEATONAL'),
    Estado         CHAR(1)           NOT NULL CONSTRAINT DF_Acceso_Estado DEFAULT ('P'),
    FechaCreacion  DATETIME2(0)      NOT NULL CONSTRAINT DF_Acceso_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila    ROWVERSION        NOT NULL,
    CONSTRAINT PK_Acceso PRIMARY KEY (AccesoID),
    CONSTRAINT FK_Acceso_Estacion FOREIGN KEY (EstacionID)
        REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT UQ_Acceso_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Acceso_Tipo CHECK (TipoAcceso IN ('PEATONAL','VEHICULAR','MIXTO','EMERGENCIA')),
    CONSTRAINT CK_Acceso_Estado CHECK (Estado IN ('P','A','I'))
);
GO

/*=============================================================================
  3. PARQUEOS, FLOTA, ASIGNACIONES, RECORRIDOS Y OCUPACION
=============================================================================*/
CREATE TABLE ops.Parqueo
(
    ParqueoID       INT IDENTITY(1,1) NOT NULL,
    EstacionID      INT               NOT NULL,
    Codigo          VARCHAR(30)       NOT NULL,
    Nombre          NVARCHAR(120)     NOT NULL,
    CapacidadBuses  SMALLINT          NOT NULL,
    Activo          BIT               NOT NULL CONSTRAINT DF_Parqueo_Activo DEFAULT (1),
    FechaCreacion   DATETIME2(0)      NOT NULL CONSTRAINT DF_Parqueo_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Parqueo PRIMARY KEY (ParqueoID),
    CONSTRAINT FK_Parqueo_Estacion FOREIGN KEY (EstacionID)
        REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT UQ_Parqueo_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Parqueo_Capacidad CHECK (CapacidadBuses > 0)
);
GO

CREATE TABLE ops.Bus
(
    BusID           INT IDENTITY(1,1) NOT NULL,
    ParqueoID       INT               NOT NULL,
    CodigoInterno   VARCHAR(30)       NOT NULL,
    Placa            VARCHAR(20)       NOT NULL,
    Marca            NVARCHAR(60)      NULL,
    Modelo           NVARCHAR(60)      NULL,
    Anio             SMALLINT          NULL,
    CapacidadMaxima  SMALLINT          NOT NULL,
    Estado           VARCHAR(20)       NOT NULL CONSTRAINT DF_Bus_Estado DEFAULT ('DISPONIBLE'),
    FechaRegistro    DATETIME2(0)      NOT NULL CONSTRAINT DF_Bus_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila      ROWVERSION        NOT NULL,
    CONSTRAINT PK_Bus PRIMARY KEY (BusID),
    CONSTRAINT FK_Bus_Parqueo FOREIGN KEY (ParqueoID)
        REFERENCES ops.Parqueo(ParqueoID),
    CONSTRAINT UQ_Bus_Codigo UNIQUE (CodigoInterno),
    CONSTRAINT UQ_Bus_Placa UNIQUE (Placa),
    CONSTRAINT CK_Bus_Anio CHECK (Anio IS NULL OR Anio BETWEEN 2000 AND 2100),
    CONSTRAINT CK_Bus_Capacidad CHECK (CapacidadMaxima > 0),
    CONSTRAINT CK_Bus_Estado CHECK (Estado IN ('DISPONIBLE','EN_RUTA','MANTENIMIENTO','INACTIVO'))
);
GO

CREATE TABLE ops.LineaBus
(
    BusID           INT          NOT NULL,
    LineaID         INT          NOT NULL,
    FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_LineaBus_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_LineaBus PRIMARY KEY (BusID),
    CONSTRAINT FK_LineaBus_Bus FOREIGN KEY (BusID) REFERENCES ops.Bus(BusID),
    CONSTRAINT FK_LineaBus_Linea FOREIGN KEY (LineaID) REFERENCES ops.Linea(LineaID)
);
GO

CREATE TABLE ops.HistorialParqueoBus
(
    HistorialParqueoID BIGINT IDENTITY(1,1) NOT NULL,
    BusID              INT                 NOT NULL,
    ParqueoAnteriorID  INT                 NULL,
    ParqueoNuevoID     INT                 NOT NULL,
    FechaCambio        DATETIME2(0)        NOT NULL CONSTRAINT DF_HistParqueo_Fecha DEFAULT SYSUTCDATETIME(),
    UsuarioCambioID    INT                 NULL,
    Motivo             NVARCHAR(300)       NULL,
    CONSTRAINT PK_HistorialParqueoBus PRIMARY KEY (HistorialParqueoID),
    CONSTRAINT FK_HistParqueo_Bus FOREIGN KEY (BusID) REFERENCES ops.Bus(BusID),
    CONSTRAINT FK_HistParqueo_Anterior FOREIGN KEY (ParqueoAnteriorID) REFERENCES ops.Parqueo(ParqueoID),
    CONSTRAINT FK_HistParqueo_Nuevo FOREIGN KEY (ParqueoNuevoID) REFERENCES ops.Parqueo(ParqueoID),
    CONSTRAINT CK_HistParqueo_Cambio CHECK (ParqueoAnteriorID IS NULL OR ParqueoAnteriorID <> ParqueoNuevoID)
);
GO

CREATE TABLE ops.Viaje
(
    ViajeID         BIGINT IDENTITY(1,1) NOT NULL,
    LineaID         INT                 NOT NULL,
    BusID           INT                 NOT NULL,
    PilotoID        INT                 NULL,
    FechaSalida     DATETIME2(0)        NOT NULL,
    FechaLlegada    DATETIME2(0)        NULL,
    Estado          VARCHAR(20)         NOT NULL CONSTRAINT DF_Viaje_Estado DEFAULT ('PROGRAMADO'),
    CONSTRAINT PK_Viaje PRIMARY KEY (ViajeID),
    CONSTRAINT FK_Viaje_Linea FOREIGN KEY (LineaID) REFERENCES ops.Linea(LineaID),
    CONSTRAINT FK_Viaje_Bus FOREIGN KEY (BusID) REFERENCES ops.Bus(BusID),
    CONSTRAINT CK_Viaje_Fechas CHECK (FechaLlegada IS NULL OR FechaLlegada >= FechaSalida),
    CONSTRAINT CK_Viaje_Estado CHECK (Estado IN ('PROGRAMADO','EN_CURSO','FINALIZADO','CANCELADO'))
);
GO

CREATE TABLE ops.VisitaEstacionViaje
(
    ViajeID         BIGINT       NOT NULL,
    EstacionID      INT          NOT NULL,
    OrdenVisita     SMALLINT     NOT NULL,
    LlegadaProgramada DATETIME2(0) NULL,
    LlegadaReal     DATETIME2(0) NULL,
    SalidaReal      DATETIME2(0) NULL,
    CONSTRAINT PK_VisitaEstacionViaje PRIMARY KEY (ViajeID, EstacionID),
    CONSTRAINT FK_Visita_Viaje FOREIGN KEY (ViajeID) REFERENCES ops.Viaje(ViajeID),
    CONSTRAINT FK_Visita_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT UQ_Visita_Orden UNIQUE (ViajeID, OrdenVisita),
    CONSTRAINT CK_Visita_Orden CHECK (OrdenVisita > 0),
    CONSTRAINT CK_Visita_Fechas CHECK (SalidaReal IS NULL OR LlegadaReal IS NULL OR SalidaReal >= LlegadaReal)
);
GO

CREATE TABLE ops.ConteoEstacion
(
    ConteoEstacionID BIGINT IDENTITY(1,1) NOT NULL,
    EstacionID       INT                 NOT NULL,
    CantidadPasajeros INT                NOT NULL,
    CapacidadEvaluada SMALLINT           NOT NULL,
    FechaRegistro    DATETIME2(0)        NOT NULL CONSTRAINT DF_Conteo_Fecha DEFAULT SYSUTCDATETIME(),
    OperadorID       INT                 NULL,
    CONSTRAINT PK_ConteoEstacion PRIMARY KEY (ConteoEstacionID),
    CONSTRAINT FK_Conteo_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT CK_Conteo_Cantidad CHECK (CantidadPasajeros >= 0),
    CONSTRAINT CK_Conteo_Capacidad CHECK (CapacidadEvaluada > 0)
);
GO

CREATE TABLE ops.AlertaOcupacion
(
    AlertaID         BIGINT IDENTITY(1,1) NOT NULL,
    ConteoEstacionID BIGINT              NOT NULL,
    EstacionID       INT                 NOT NULL,
    Porcentaje       DECIMAL(7,2)        NOT NULL,
    RequiereUnidad   BIT                 NOT NULL CONSTRAINT DF_Alerta_Unidad DEFAULT (1),
    Estado           VARCHAR(20)         NOT NULL CONSTRAINT DF_Alerta_Estado DEFAULT ('PENDIENTE'),
    FechaGeneracion  DATETIME2(0)        NOT NULL CONSTRAINT DF_Alerta_Fecha DEFAULT SYSUTCDATETIME(),
    FechaAtencion    DATETIME2(0)        NULL,
    Observacion      NVARCHAR(500)       NULL,
    CONSTRAINT PK_AlertaOcupacion PRIMARY KEY (AlertaID),
    CONSTRAINT FK_Alerta_Conteo FOREIGN KEY (ConteoEstacionID) REFERENCES ops.ConteoEstacion(ConteoEstacionID),
    CONSTRAINT FK_Alerta_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT UQ_Alerta_Conteo UNIQUE (ConteoEstacionID),
    CONSTRAINT CK_Alerta_Porcentaje CHECK (Porcentaje >= 150),
    CONSTRAINT CK_Alerta_Estado CHECK (Estado IN ('PENDIENTE','ATENDIDA','CANCELADA'))
);
GO

CREATE TABLE ops.RegistroOcupacionBus
(
    RegistroOcupacionID BIGINT IDENTITY(1,1) NOT NULL,
    BusID               INT                 NOT NULL,
    EstacionID          INT                 NOT NULL,
    ViajeID             BIGINT              NULL,
    CantidadPasajeros   SMALLINT            NOT NULL,
    CapacidadEvaluada   SMALLINT            NOT NULL,
    PorcentajeOcupacion DECIMAL(7,2)        NOT NULL,
    FechaRegistro       DATETIME2(0)        NOT NULL CONSTRAINT DF_RegOcupacion_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_RegistroOcupacionBus PRIMARY KEY (RegistroOcupacionID),
    CONSTRAINT FK_RegOcupacion_Bus FOREIGN KEY (BusID) REFERENCES ops.Bus(BusID),
    CONSTRAINT FK_RegOcupacion_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT FK_RegOcupacion_Viaje FOREIGN KEY (ViajeID) REFERENCES ops.Viaje(ViajeID),
    CONSTRAINT CK_RegOcupacion_Cantidad CHECK (CantidadPasajeros >= 0),
    CONSTRAINT CK_RegOcupacion_Capacidad CHECK (CapacidadEvaluada > 0),
    CONSTRAINT CK_RegOcupacion_Porcentaje CHECK (PorcentajeOcupacion >= 0)
);
GO

CREATE TABLE ops.EsperaAdicional
(
    EsperaID            BIGINT IDENTITY(1,1) NOT NULL,
    RegistroOcupacionID BIGINT              NOT NULL,
    MinutosAdicionales  TINYINT             NOT NULL CONSTRAINT DF_Espera_Minutos DEFAULT (5),
    Aplicada            BIT                 NOT NULL CONSTRAINT DF_Espera_Aplicada DEFAULT (0),
    FechaIndicacion     DATETIME2(0)        NOT NULL CONSTRAINT DF_Espera_Fecha DEFAULT SYSUTCDATETIME(),
    FechaAplicacion     DATETIME2(0)        NULL,
    CONSTRAINT PK_EsperaAdicional PRIMARY KEY (EsperaID),
    CONSTRAINT FK_Espera_Registro FOREIGN KEY (RegistroOcupacionID)
        REFERENCES ops.RegistroOcupacionBus(RegistroOcupacionID),
    CONSTRAINT UQ_Espera_Registro UNIQUE (RegistroOcupacionID),
    CONSTRAINT CK_Espera_Minutos CHECK (MinutosAdicionales = 5)
);
GO

/*=============================================================================
  4. PERSONAL: PILOTOS, EDUCACION, GUARDIAS Y OPERADORES
=============================================================================*/
CREATE TABLE ops.Piloto
(
    PilotoID        INT IDENTITY(1,1) NOT NULL,
    CodigoEmpleado  VARCHAR(30)       NOT NULL,
    Nombres         NVARCHAR(100)     NOT NULL,
    Apellidos       NVARCHAR(100)     NOT NULL,
    DPIHash          VARBINARY(64)     NULL,
    Direccion       NVARCHAR(300)     NOT NULL,
    Municipio       NVARCHAR(100)     NOT NULL,
    Departamento    NVARCHAR(100)     NOT NULL,
    Telefono        VARCHAR(25)       NOT NULL,
    Correo          VARCHAR(254)      NULL,
    Licencia        VARCHAR(30)       NOT NULL,
    FechaVencimientoLicencia DATE      NOT NULL,
    Activo          BIT               NOT NULL CONSTRAINT DF_Piloto_Activo DEFAULT (1),
    FechaRegistro   DATETIME2(0)      NOT NULL CONSTRAINT DF_Piloto_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila     ROWVERSION        NOT NULL,
    CONSTRAINT PK_Piloto PRIMARY KEY (PilotoID),
    CONSTRAINT UQ_Piloto_Codigo UNIQUE (CodigoEmpleado),
    CONSTRAINT UQ_Piloto_Licencia UNIQUE (Licencia),
    CONSTRAINT CK_Piloto_Correo CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')
);
GO

CREATE TABLE ops.HistorialEducativoPiloto
(
    HistorialEducativoID INT IDENTITY(1,1) NOT NULL,
    PilotoID             INT               NOT NULL,
    Nivel                VARCHAR(30)       NOT NULL,
    Institucion          NVARCHAR(200)     NOT NULL,
    Titulo               NVARCHAR(200)     NULL,
    AnioFinalizacion     SMALLINT          NULL,
    Observacion          NVARCHAR(500)     NULL,
    CONSTRAINT PK_HistorialEducativoPiloto PRIMARY KEY (HistorialEducativoID),
    CONSTRAINT FK_HistorialEducativo_Piloto FOREIGN KEY (PilotoID) REFERENCES ops.Piloto(PilotoID),
    CONSTRAINT CK_HistorialEducativo_Nivel CHECK (Nivel IN ('PRIMARIA','BASICOS','DIVERSIFICADO','TECNICO','UNIVERSITARIO','OTRO')),
    CONSTRAINT CK_HistorialEducativo_Anio CHECK (AnioFinalizacion IS NULL OR AnioFinalizacion BETWEEN 1950 AND 2100)
);
GO

ALTER TABLE ops.Viaje
ADD CONSTRAINT FK_Viaje_Piloto FOREIGN KEY (PilotoID) REFERENCES ops.Piloto(PilotoID);
GO

CREATE TABLE ops.Guardia
(
    GuardiaID       INT IDENTITY(1,1) NOT NULL,
    CodigoEmpleado  VARCHAR(30)       NOT NULL,
    Nombres         NVARCHAR(100)     NOT NULL,
    Apellidos       NVARCHAR(100)     NOT NULL,
    Telefono        VARCHAR(25)       NULL,
    Empresa         NVARCHAR(150)     NULL,
    Activo          BIT               NOT NULL CONSTRAINT DF_Guardia_Activo DEFAULT (1),
    FechaRegistro   DATETIME2(0)      NOT NULL CONSTRAINT DF_Guardia_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Guardia PRIMARY KEY (GuardiaID),
    CONSTRAINT UQ_Guardia_Codigo UNIQUE (CodigoEmpleado)
);
GO

CREATE TABLE ops.AsignacionGuardiaAcceso
(
    AsignacionGuardiaID BIGINT IDENTITY(1,1) NOT NULL,
    GuardiaID           INT                 NOT NULL,
    AccesoID            INT                 NOT NULL,
    FechaInicio         DATETIME2(0)        NOT NULL CONSTRAINT DF_AsigGuardia_Inicio DEFAULT SYSUTCDATETIME(),
    FechaFin            DATETIME2(0)        NULL,
    Turno               VARCHAR(20)         NOT NULL CONSTRAINT DF_AsigGuardia_Turno DEFAULT ('DIURNO'),
    CONSTRAINT PK_AsignacionGuardiaAcceso PRIMARY KEY (AsignacionGuardiaID),
    CONSTRAINT FK_AsigGuardia_Guardia FOREIGN KEY (GuardiaID) REFERENCES ops.Guardia(GuardiaID),
    CONSTRAINT FK_AsigGuardia_Acceso FOREIGN KEY (AccesoID) REFERENCES ops.Acceso(AccesoID),
    CONSTRAINT CK_AsigGuardia_Fechas CHECK (FechaFin IS NULL OR FechaFin > FechaInicio),
    CONSTRAINT CK_AsigGuardia_Turno CHECK (Turno IN ('DIURNO','NOCTURNO','MIXTO'))
);
GO

CREATE UNIQUE INDEX UX_AsigGuardia_Activa
ON ops.AsignacionGuardiaAcceso(GuardiaID)
WHERE FechaFin IS NULL;
GO

CREATE TABLE ops.Operador
(
    OperadorID      INT IDENTITY(1,1) NOT NULL,
    CodigoEmpleado  VARCHAR(30)       NOT NULL,
    Nombres         NVARCHAR(100)     NOT NULL,
    Apellidos       NVARCHAR(100)     NOT NULL,
    Telefono        VARCHAR(25)       NULL,
    Correo          VARCHAR(254)      NULL,
    Activo          BIT               NOT NULL CONSTRAINT DF_Operador_Activo DEFAULT (1),
    FechaRegistro   DATETIME2(0)      NOT NULL CONSTRAINT DF_Operador_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Operador PRIMARY KEY (OperadorID),
    CONSTRAINT UQ_Operador_Codigo UNIQUE (CodigoEmpleado),
    CONSTRAINT CK_Operador_Correo CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')
);
GO

CREATE TABLE ops.AsignacionOperadorEstacion
(
    AsignacionOperadorID BIGINT IDENTITY(1,1) NOT NULL,
    OperadorID           INT                 NOT NULL,
    EstacionID           INT                 NOT NULL,
    FechaInicio          DATETIME2(0)        NOT NULL CONSTRAINT DF_AsigOperador_Inicio DEFAULT SYSUTCDATETIME(),
    FechaFin             DATETIME2(0)        NULL,
    CONSTRAINT PK_AsignacionOperadorEstacion PRIMARY KEY (AsignacionOperadorID),
    CONSTRAINT FK_AsigOperador_Operador FOREIGN KEY (OperadorID) REFERENCES ops.Operador(OperadorID),
    CONSTRAINT FK_AsigOperador_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT CK_AsigOperador_Fechas CHECK (FechaFin IS NULL OR FechaFin > FechaInicio)
);
GO

CREATE UNIQUE INDEX UX_AsigOperador_OperadorActivo
ON ops.AsignacionOperadorEstacion(OperadorID)
WHERE FechaFin IS NULL;
GO
CREATE UNIQUE INDEX UX_AsigOperador_EstacionActiva
ON ops.AsignacionOperadorEstacion(EstacionID)
WHERE FechaFin IS NULL;
GO

/* FK diferidas de responsables que ya cuentan con tabla de personal. */
ALTER TABLE ops.ConteoEstacion
ADD CONSTRAINT FK_Conteo_Operador FOREIGN KEY (OperadorID) REFERENCES ops.Operador(OperadorID);
GO

/*=============================================================================
  5. USUARIOS, ROLES, PERMISOS Y AUDITORIA
=============================================================================*/
CREATE TABLE seg.Usuario
(
    UsuarioID        INT IDENTITY(1,1) NOT NULL,
    OperadorID       INT               NULL,
    NombreUsuario    NVARCHAR(100)     NOT NULL,
    Correo           VARCHAR(254)      NOT NULL,
    ContrasenaHash   VARBINARY(64)     NOT NULL,
    ContrasenaSalt   VARBINARY(32)     NOT NULL,
    Activo           BIT               NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT (1),
    IntentosFallidos TINYINT           NOT NULL CONSTRAINT DF_Usuario_Intentos DEFAULT (0),
    BloqueadoHasta   DATETIME2(0)      NULL,
    UltimoAcceso     DATETIME2(0)      NULL,
    FechaCreacion    DATETIME2(0)      NOT NULL CONSTRAINT DF_Usuario_Fecha DEFAULT SYSUTCDATETIME(),
    VersionFila      ROWVERSION        NOT NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY (UsuarioID),
    CONSTRAINT FK_Usuario_Operador FOREIGN KEY (OperadorID) REFERENCES ops.Operador(OperadorID),
    CONSTRAINT UQ_Usuario_Nombre UNIQUE (NombreUsuario),
    CONSTRAINT UQ_Usuario_Correo UNIQUE (Correo),
    CONSTRAINT UQ_Usuario_Operador UNIQUE (OperadorID),
    CONSTRAINT CK_Usuario_Correo CHECK (Correo LIKE '%_@_%._%'),
    CONSTRAINT CK_Usuario_Intentos CHECK (IntentosFallidos BETWEEN 0 AND 10)
);
GO

CREATE TABLE seg.Rol
(
    RolID       SMALLINT IDENTITY(1,1) NOT NULL,
    Nombre      NVARCHAR(80)           NOT NULL,
    Descripcion NVARCHAR(300)          NULL,
    Activo      BIT                    NOT NULL CONSTRAINT DF_Rol_Activo DEFAULT (1),
    CONSTRAINT PK_Rol PRIMARY KEY (RolID),
    CONSTRAINT UQ_Rol_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE seg.Permiso
(
    PermisoID   SMALLINT IDENTITY(1,1) NOT NULL,
    Codigo      VARCHAR(80)            NOT NULL,
    Descripcion NVARCHAR(300)          NOT NULL,
    CONSTRAINT PK_Permiso PRIMARY KEY (PermisoID),
    CONSTRAINT UQ_Permiso_Codigo UNIQUE (Codigo)
);
GO

CREATE TABLE seg.UsuarioRol
(
    UsuarioID      INT          NOT NULL,
    RolID          SMALLINT     NOT NULL,
    FechaAsignacion DATETIME2(0) NOT NULL CONSTRAINT DF_UsuarioRol_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UsuarioRol PRIMARY KEY (UsuarioID, RolID),
    CONSTRAINT FK_UsuarioRol_Usuario FOREIGN KEY (UsuarioID) REFERENCES seg.Usuario(UsuarioID),
    CONSTRAINT FK_UsuarioRol_Rol FOREIGN KEY (RolID) REFERENCES seg.Rol(RolID)
);
GO

CREATE TABLE seg.RolPermiso
(
    RolID     SMALLINT NOT NULL,
    PermisoID SMALLINT NOT NULL,
    CONSTRAINT PK_RolPermiso PRIMARY KEY (RolID, PermisoID),
    CONSTRAINT FK_RolPermiso_Rol FOREIGN KEY (RolID) REFERENCES seg.Rol(RolID),
    CONSTRAINT FK_RolPermiso_Permiso FOREIGN KEY (PermisoID) REFERENCES seg.Permiso(PermisoID)
);
GO

CREATE TABLE aud.Bitacora
(
    BitacoraID     BIGINT IDENTITY(1,1) NOT NULL,
    UsuarioID      INT                 NULL,
    Esquema        SYSNAME             NOT NULL,
    Tabla          SYSNAME             NOT NULL,
    Operacion      CHAR(1)             NOT NULL,
    ClaveRegistro  NVARCHAR(200)       NULL,
    DatosAnteriores NVARCHAR(MAX)      NULL,
    DatosNuevos    NVARCHAR(MAX)       NULL,
    FechaHora      DATETIME2(3)        NOT NULL CONSTRAINT DF_Bitacora_Fecha DEFAULT SYSUTCDATETIME(),
    UsuarioBD      SYSNAME             NOT NULL CONSTRAINT DF_Bitacora_UsuarioBD DEFAULT ORIGINAL_LOGIN(),
    DireccionIP    VARCHAR(48)         NULL,
    CONSTRAINT PK_Bitacora PRIMARY KEY (BitacoraID),
    CONSTRAINT FK_Bitacora_Usuario FOREIGN KEY (UsuarioID) REFERENCES seg.Usuario(UsuarioID),
    CONSTRAINT CK_Bitacora_Operacion CHECK (Operacion IN ('I','U','D')),
    CONSTRAINT CK_Bitacora_JSON_Anterior CHECK (DatosAnteriores IS NULL OR ISJSON(DatosAnteriores) = 1),
    CONSTRAINT CK_Bitacora_JSON_Nuevo CHECK (DatosNuevos IS NULL OR ISJSON(DatosNuevos) = 1)
);
GO

ALTER TABLE ops.HistorialParqueoBus
ADD CONSTRAINT FK_HistParqueo_Usuario FOREIGN KEY (UsuarioCambioID) REFERENCES seg.Usuario(UsuarioID);
GO

/*=============================================================================
  6. TARJETAS, RECARGAS Y PAGOS
=============================================================================*/
CREATE TABLE fin.TitularTarjeta
(
    TitularID      BIGINT IDENTITY(1,1) NOT NULL,
    Nombres        NVARCHAR(100)        NOT NULL,
    Apellidos      NVARCHAR(100)        NOT NULL,
    Correo         VARCHAR(254)         NULL,
    Telefono       VARCHAR(25)          NULL,
    DocumentoHash  VARBINARY(64)        NULL,
    FechaRegistro  DATETIME2(0)         NOT NULL CONSTRAINT DF_Titular_Fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_TitularTarjeta PRIMARY KEY (TitularID),
    CONSTRAINT CK_Titular_Correo CHECK (Correo IS NULL OR Correo LIKE '%_@_%._%')
);
GO

CREATE TABLE fin.TarjetaAcceso
(
    TarjetaID      BIGINT IDENTITY(1,1) NOT NULL,
    TitularID      BIGINT              NULL,
    NumeroToken    VARCHAR(64)         NOT NULL,
    Saldo          DECIMAL(12,2)       NOT NULL CONSTRAINT DF_Tarjeta_Saldo DEFAULT (0),
    Estado         VARCHAR(20)         NOT NULL CONSTRAINT DF_Tarjeta_Estado DEFAULT ('ACTIVA'),
    FechaEmision   DATE                NOT NULL CONSTRAINT DF_Tarjeta_Emision DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    FechaVencimiento DATE              NULL,
    VersionFila    ROWVERSION          NOT NULL,
    CONSTRAINT PK_TarjetaAcceso PRIMARY KEY (TarjetaID),
    CONSTRAINT FK_Tarjeta_Titular FOREIGN KEY (TitularID) REFERENCES fin.TitularTarjeta(TitularID),
    CONSTRAINT UQ_Tarjeta_Token UNIQUE (NumeroToken),
    CONSTRAINT CK_Tarjeta_Saldo CHECK (Saldo >= 0),
    CONSTRAINT CK_Tarjeta_Estado CHECK (Estado IN ('ACTIVA','BLOQUEADA','VENCIDA','INACTIVA')),
    CONSTRAINT CK_Tarjeta_Vigencia CHECK (FechaVencimiento IS NULL OR FechaVencimiento >= FechaEmision)
);
GO

CREATE TABLE fin.TransaccionTarjeta
(
    TransaccionID  BIGINT IDENTITY(1,1) NOT NULL,
    TarjetaID      BIGINT              NOT NULL,
    EstacionID     INT                 NULL,
    Tipo           CHAR(1)             NOT NULL,
    Monto          DECIMAL(12,2)       NOT NULL,
    SaldoAnterior  DECIMAL(12,2)       NOT NULL,
    SaldoNuevo     DECIMAL(12,2)       NOT NULL,
    Referencia     VARCHAR(80)         NOT NULL,
    FechaHora      DATETIME2(0)        NOT NULL CONSTRAINT DF_Transaccion_Fecha DEFAULT SYSUTCDATETIME(),
    UsuarioID      INT                 NULL,
    CONSTRAINT PK_TransaccionTarjeta PRIMARY KEY (TransaccionID),
    CONSTRAINT FK_Transaccion_Tarjeta FOREIGN KEY (TarjetaID) REFERENCES fin.TarjetaAcceso(TarjetaID),
    CONSTRAINT FK_Transaccion_Estacion FOREIGN KEY (EstacionID) REFERENCES ops.Estacion(EstacionID),
    CONSTRAINT FK_Transaccion_Usuario FOREIGN KEY (UsuarioID) REFERENCES seg.Usuario(UsuarioID),
    CONSTRAINT UQ_Transaccion_Referencia UNIQUE (Referencia),
    CONSTRAINT CK_Transaccion_Tipo CHECK (Tipo IN ('R','P')),
    CONSTRAINT CK_Transaccion_Monto CHECK (Monto > 0),
    CONSTRAINT CK_Transaccion_Saldos CHECK (SaldoAnterior >= 0 AND SaldoNuevo >= 0),
    CONSTRAINT CK_Transaccion_Calculo CHECK
    (
        (Tipo = 'R' AND SaldoNuevo = SaldoAnterior + Monto) OR
        (Tipo = 'P' AND SaldoNuevo = SaldoAnterior - Monto)
    )
);
GO

/*=============================================================================
  7. INDICES DE CONSULTA Y RENDIMIENTO
=============================================================================*/
CREATE INDEX IX_Linea_Municipalidad ON ops.Linea(MunicipalidadID, Estado);
CREATE INDEX IX_Estacion_Municipalidad ON ops.Estacion(MunicipalidadID, Estado);
CREATE INDEX IX_LineaEstacion_Estacion ON ops.LineaEstacion(EstacionID, LineaID);
CREATE INDEX IX_Acceso_Estacion ON ops.Acceso(EstacionID, Estado);
CREATE INDEX IX_Parqueo_Estacion ON ops.Parqueo(EstacionID, Activo);
CREATE INDEX IX_LineaBus_Linea ON ops.LineaBus(LineaID, BusID);
CREATE INDEX IX_Alerta_EstadoFecha ON ops.AlertaOcupacion(Estado, FechaGeneracion DESC);
CREATE INDEX IX_Conteo_EstacionFecha ON ops.ConteoEstacion(EstacionID, FechaRegistro DESC);
CREATE INDEX IX_RegOcupacion_BusFecha ON ops.RegistroOcupacionBus(BusID, FechaRegistro DESC);
CREATE INDEX IX_Transaccion_TarjetaFecha ON fin.TransaccionTarjeta(TarjetaID, FechaHora DESC);
CREATE INDEX IX_Bitacora_TablaFecha ON aud.Bitacora(Esquema, Tabla, FechaHora DESC);
CREATE INDEX IX_Bitacora_UsuarioFecha ON aud.Bitacora(UsuarioID, FechaHora DESC);
GO

/*=============================================================================
  8. TRIGGERS DE REGLAS DE NEGOCIO
=============================================================================*/
CREATE OR ALTER TRIGGER ops.tr_TramoLinea_Consecutivo
ON ops.TramoLinea
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN ops.LineaEstacion o ON o.LineaID=i.LineaID AND o.EstacionID=i.EstacionOrigenID
        JOIN ops.LineaEstacion d ON d.LineaID=i.LineaID AND d.EstacionID=i.EstacionDestinoID
        WHERE d.Orden <> o.Orden + 1
    )
        THROW 51001, 'El tramo solo puede relacionar estaciones consecutivas de la misma linea.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_LineaBus_Reglas
ON ops.LineaBus
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM ops.Linea l
        CROSS APPLY (SELECT COUNT(*) CantEst FROM ops.LineaEstacion le WHERE le.LineaID=l.LineaID) e
        CROSS APPLY (SELECT COUNT(*) CantBus FROM ops.LineaBus lb WHERE lb.LineaID=l.LineaID) b
        WHERE l.LineaID IN (SELECT LineaID FROM inserted UNION SELECT LineaID FROM deleted)
          AND
          (
              b.CantBus > 2 * e.CantEst
              OR (l.Estado='A' AND (e.CantEst=0 OR b.CantBus < e.CantEst))
          )
    )
        THROW 51002, 'La linea activa debe tener entre una y dos veces la cantidad de buses respecto de sus estaciones.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_LineaEstacion_Reglas
ON ops.LineaEstacion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM ops.Linea l
        CROSS APPLY (SELECT COUNT(*) CantEst FROM ops.LineaEstacion le WHERE le.LineaID=l.LineaID) e
        CROSS APPLY (SELECT COUNT(*) CantBus FROM ops.LineaBus lb WHERE lb.LineaID=l.LineaID) b
        WHERE l.LineaID IN (SELECT LineaID FROM inserted UNION SELECT LineaID FROM deleted)
          AND l.Estado='A'
          AND (e.CantEst=0 OR b.CantBus < e.CantEst OR b.CantBus > 2*e.CantEst)
    )
        THROW 51003, 'El cambio deja una linea activa fuera del limite permitido de buses.', 1;

    IF EXISTS
    (
        SELECT 1
        FROM ops.Estacion e
        WHERE e.EstacionID IN (SELECT EstacionID FROM deleted)
          AND e.Estado='A'
          AND NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le WHERE le.EstacionID=e.EstacionID)
    )
        THROW 51004, 'Una estacion activa debe pertenecer al menos a una linea.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_GuardiaAcceso_Minimo
ON ops.AsignacionGuardiaAcceso
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM ops.Acceso a
        WHERE a.AccesoID IN (SELECT AccesoID FROM deleted)
          AND a.Estado='A'
          AND NOT EXISTS
              (SELECT 1 FROM ops.AsignacionGuardiaAcceso x
               WHERE x.AccesoID=a.AccesoID AND x.FechaFin IS NULL)
    )
        THROW 51005, 'Un acceso activo debe conservar por lo menos un guardia asignado.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_OperadorEstacion_Minimo
ON ops.AsignacionOperadorEstacion
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM ops.Estacion e
        WHERE e.EstacionID IN (SELECT EstacionID FROM deleted)
          AND e.Estado='A'
          AND NOT EXISTS
              (SELECT 1 FROM ops.AsignacionOperadorEstacion x
               WHERE x.EstacionID=e.EstacionID AND x.FechaFin IS NULL)
    )
        THROW 51006, 'Una estacion activa debe conservar un operador responsable.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_Bus_HistorialParqueo
ON ops.Bus
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1 FROM inserted i
        JOIN ops.Parqueo p ON p.ParqueoID=i.ParqueoID
        WHERE p.Activo=0
           OR (SELECT COUNT(*) FROM ops.Bus b WHERE b.ParqueoID=i.ParqueoID)>p.CapacidadBuses
    )
        THROW 51014, 'El parqueo esta inactivo o no tiene espacios disponibles.', 1;

    INSERT ops.HistorialParqueoBus
        (BusID, ParqueoAnteriorID, ParqueoNuevoID, UsuarioCambioID, Motivo)
    SELECT i.BusID, d.ParqueoID, i.ParqueoID,
           TRY_CONVERT(INT, SESSION_CONTEXT(N'UsuarioAplicacionID')),
           N'Reasignacion de parqueo'
    FROM inserted i
    JOIN deleted d ON d.BusID=i.BusID
    WHERE i.ParqueoID <> d.ParqueoID;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_AsignacionGuardia_ValidarActivo
ON ops.AsignacionGuardiaAcceso
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1 FROM inserted i
        JOIN ops.Guardia g ON g.GuardiaID=i.GuardiaID
        JOIN ops.Acceso a ON a.AccesoID=i.AccesoID
        WHERE i.FechaFin IS NULL AND (g.Activo=0 OR a.Estado='I')
    )
        THROW 51015, 'Una asignacion vigente requiere un guardia activo y un acceso no inactivo.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_AsignacionOperador_ValidarActivo
ON ops.AsignacionOperadorEstacion
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1 FROM inserted i
        JOIN ops.Operador o ON o.OperadorID=i.OperadorID
        JOIN ops.Estacion e ON e.EstacionID=i.EstacionID
        WHERE i.FechaFin IS NULL AND (o.Activo=0 OR e.Estado='I')
    )
        THROW 51016, 'Una asignacion vigente requiere un operador activo y una estacion no inactiva.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_Viaje_ValidarAsignacion
ON ops.Viaje
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        WHERE i.Estado<>'CANCELADO'
          AND NOT EXISTS
              (SELECT 1 FROM ops.LineaBus lb WHERE lb.BusID=i.BusID AND lb.LineaID=i.LineaID)
    )
        THROW 51008, 'El bus del viaje debe encontrarse asignado a la linea seleccionada.', 1;
    IF EXISTS
    (
        SELECT 1 FROM inserted i
        JOIN ops.Piloto p ON p.PilotoID=i.PilotoID
        WHERE p.Activo=0
    )
        THROW 51009, 'No se puede asignar un piloto inactivo al viaje.', 1;
END;
GO

CREATE OR ALTER TRIGGER ops.tr_VisitaEstacion_ValidarRuta
ON ops.VisitaEstacionViaje
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        JOIN ops.Viaje v ON v.ViajeID=i.ViajeID
        LEFT JOIN ops.LineaEstacion le
          ON le.LineaID=v.LineaID AND le.EstacionID=i.EstacionID AND le.Orden=i.OrdenVisita
        WHERE le.LineaID IS NULL
    )
        THROW 51010, 'La visita debe respetar las estaciones y el orden definido para la linea del viaje.', 1;
END;
GO

CREATE OR ALTER TRIGGER fin.tr_Tarjeta_ProtegerSaldo
ON fin.TarjetaAcceso
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON d.TarjetaID=i.TarjetaID WHERE i.Saldo <> d.Saldo)
       AND TRY_CONVERT(INT, SESSION_CONTEXT(N'MovimientoTarjetaAutorizado')) <> 1
        THROW 51007, 'El saldo solo puede modificarse mediante fin.sp_RegistrarMovimientoTarjeta.', 1;
END;
GO

CREATE OR ALTER TRIGGER fin.tr_Transaccion_ProtegerHistorial
ON fin.TransaccionTarjeta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF TRY_CONVERT(INT, SESSION_CONTEXT(N'MovimientoTarjetaAutorizado')) <> 1
        THROW 51011, 'Las transacciones solo pueden registrarse mediante fin.sp_RegistrarMovimientoTarjeta y no pueden editarse ni eliminarse.', 1;
    IF EXISTS (SELECT 1 FROM deleted)
        THROW 51012, 'El historial financiero es inmutable; no se permite actualizar ni eliminar transacciones.', 1;
    IF EXISTS
    (
        SELECT 1 FROM inserted i
        JOIN fin.TarjetaAcceso t ON t.TarjetaID=i.TarjetaID
        WHERE t.Saldo<>i.SaldoNuevo
    )
        THROW 51013, 'El saldo de la tarjeta no coincide con el saldo final de la transaccion.', 1;
END;
GO

/* Auditoria de las entidades criticas. Se guarda JSON anterior/nuevo. */
CREATE OR ALTER TRIGGER ops.tr_Linea_Auditoria ON ops.Linea AFTER INSERT, UPDATE, DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT aud.Bitacora(UsuarioID,Esquema,Tabla,Operacion,ClaveRegistro,DatosAnteriores,DatosNuevos,DireccionIP)
 SELECT TRY_CONVERT(INT,SESSION_CONTEXT(N'UsuarioAplicacionID')),N'ops',N'Linea',
        CASE WHEN i.LineaID IS NULL THEN 'D' WHEN d.LineaID IS NULL THEN 'I' ELSE 'U' END,
        CONVERT(NVARCHAR(200),COALESCE(i.LineaID,d.LineaID)),
        CASE WHEN d.LineaID IS NULL THEN NULL ELSE (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.LineaID IS NULL THEN NULL ELSE (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CONVERT(VARCHAR(48),CONNECTIONPROPERTY('client_net_address'))
 FROM inserted i FULL JOIN deleted d ON d.LineaID=i.LineaID;
END;
GO
CREATE OR ALTER TRIGGER ops.tr_Estacion_Auditoria ON ops.Estacion AFTER INSERT, UPDATE, DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT aud.Bitacora(UsuarioID,Esquema,Tabla,Operacion,ClaveRegistro,DatosAnteriores,DatosNuevos,DireccionIP)
 SELECT TRY_CONVERT(INT,SESSION_CONTEXT(N'UsuarioAplicacionID')),N'ops',N'Estacion',
        CASE WHEN i.EstacionID IS NULL THEN 'D' WHEN d.EstacionID IS NULL THEN 'I' ELSE 'U' END,
        CONVERT(NVARCHAR(200),COALESCE(i.EstacionID,d.EstacionID)),
        CASE WHEN d.EstacionID IS NULL THEN NULL ELSE (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.EstacionID IS NULL THEN NULL ELSE (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CONVERT(VARCHAR(48),CONNECTIONPROPERTY('client_net_address'))
 FROM inserted i FULL JOIN deleted d ON d.EstacionID=i.EstacionID;
END;
GO
CREATE OR ALTER TRIGGER ops.tr_Bus_Auditoria ON ops.Bus AFTER INSERT, UPDATE, DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT aud.Bitacora(UsuarioID,Esquema,Tabla,Operacion,ClaveRegistro,DatosAnteriores,DatosNuevos,DireccionIP)
 SELECT TRY_CONVERT(INT,SESSION_CONTEXT(N'UsuarioAplicacionID')),N'ops',N'Bus',
        CASE WHEN i.BusID IS NULL THEN 'D' WHEN d.BusID IS NULL THEN 'I' ELSE 'U' END,
        CONVERT(NVARCHAR(200),COALESCE(i.BusID,d.BusID)),
        CASE WHEN d.BusID IS NULL THEN NULL ELSE (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.BusID IS NULL THEN NULL ELSE (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CONVERT(VARCHAR(48),CONNECTIONPROPERTY('client_net_address'))
 FROM inserted i FULL JOIN deleted d ON d.BusID=i.BusID;
END;
GO
CREATE OR ALTER TRIGGER fin.tr_Tarjeta_Auditoria ON fin.TarjetaAcceso AFTER INSERT, UPDATE, DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT aud.Bitacora(UsuarioID,Esquema,Tabla,Operacion,ClaveRegistro,DatosAnteriores,DatosNuevos,DireccionIP)
 SELECT TRY_CONVERT(INT,SESSION_CONTEXT(N'UsuarioAplicacionID')),N'fin',N'TarjetaAcceso',
        CASE WHEN i.TarjetaID IS NULL THEN 'D' WHEN d.TarjetaID IS NULL THEN 'I' ELSE 'U' END,
        CONVERT(NVARCHAR(200),COALESCE(i.TarjetaID,d.TarjetaID)),
        CASE WHEN d.TarjetaID IS NULL THEN NULL ELSE (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CASE WHEN i.TarjetaID IS NULL THEN NULL ELSE (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) END,
        CONVERT(VARCHAR(48),CONNECTIONPROPERTY('client_net_address'))
 FROM inserted i FULL JOIN deleted d ON d.TarjetaID=i.TarjetaID;
END;
GO

/*=============================================================================
  9. PROCEDIMIENTOS TRANSACCIONALES
=============================================================================*/
CREATE OR ALTER PROCEDURE ops.sp_ActivarLinea
    @LineaID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Estaciones INT=(SELECT COUNT(*) FROM ops.LineaEstacion WHERE LineaID=@LineaID),
            @Buses INT=(SELECT COUNT(*) FROM ops.LineaBus WHERE LineaID=@LineaID);
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE LineaID=@LineaID)
        THROW 51100, 'La linea indicada no existe.', 1;
    IF @Estaciones=0 OR @Buses<@Estaciones OR @Buses>2*@Estaciones
        THROW 51101, 'No se puede activar: la linea debe tener estaciones y entre una y dos veces esa cantidad de buses.', 1;
    IF EXISTS
    (
        SELECT 1 FROM ops.LineaEstacion le
        LEFT JOIN ops.TramoLinea t ON t.LineaID=le.LineaID AND t.EstacionOrigenID=le.EstacionID
        WHERE le.LineaID=@LineaID
          AND le.Orden < @Estaciones
          AND t.TramoID IS NULL
    )
        THROW 51102, 'No se puede activar: faltan distancias entre estaciones consecutivas.', 1;
    UPDATE ops.Linea SET Estado='A' WHERE LineaID=@LineaID;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_ActivarEstacion
    @EstacionID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE EstacionID=@EstacionID)
        THROW 51103, 'La estacion indicada no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion WHERE EstacionID=@EstacionID)
        THROW 51104, 'La estacion debe pertenecer al menos a una linea.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.AsignacionOperadorEstacion WHERE EstacionID=@EstacionID AND FechaFin IS NULL)
        THROW 51105, 'La estacion debe tener un operador responsable.', 1;
    UPDATE ops.Estacion SET Estado='A' WHERE EstacionID=@EstacionID;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_ActivarAcceso
    @AccesoID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ops.Acceso WHERE AccesoID=@AccesoID)
        THROW 51106, 'El acceso indicado no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.AsignacionGuardiaAcceso WHERE AccesoID=@AccesoID AND FechaFin IS NULL)
        THROW 51107, 'El acceso debe tener por lo menos un guardia asignado.', 1;
    UPDATE ops.Acceso SET Estado='A' WHERE AccesoID=@AccesoID;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_AsignarBusLinea
    @BusID INT,
    @LineaID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRAN;
    IF NOT EXISTS (SELECT 1 FROM ops.Bus WITH (UPDLOCK,HOLDLOCK) WHERE BusID=@BusID)
        THROW 51110, 'El bus indicado no existe.', 1;
    IF EXISTS (SELECT 1 FROM ops.LineaBus WHERE BusID=@BusID)
        THROW 51111, 'El bus ya se encuentra asignado a una linea.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE LineaID=@LineaID AND Estado<>'I')
        THROW 51112, 'La linea indicada no existe o esta inactiva.', 1;

    DECLARE @Estaciones INT=(SELECT COUNT(*) FROM ops.LineaEstacion WHERE LineaID=@LineaID),
            @Buses INT=(SELECT COUNT(*) FROM ops.LineaBus WITH (UPDLOCK,HOLDLOCK) WHERE LineaID=@LineaID);
    IF @Estaciones=0 OR @Buses+1 > 2*@Estaciones
        THROW 51113, 'La asignacion supera el maximo de dos buses por estacion o la linea no tiene estaciones.', 1;

    INSERT ops.LineaBus(BusID,LineaID) VALUES(@BusID,@LineaID);
    COMMIT;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_ReasignarParqueoBus
    @BusID INT,
    @ParqueoNuevoID INT,
    @Motivo NVARCHAR(300)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRAN;
    IF NOT EXISTS (SELECT 1 FROM ops.Parqueo WHERE ParqueoID=@ParqueoNuevoID AND Activo=1)
        THROW 51120, 'El parqueo nuevo no existe o esta inactivo.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.Bus WITH (UPDLOCK,HOLDLOCK) WHERE BusID=@BusID)
        THROW 51121, 'El bus indicado no existe.', 1;
    UPDATE ops.Bus SET ParqueoID=@ParqueoNuevoID WHERE BusID=@BusID;
    IF @Motivo IS NOT NULL
        UPDATE ops.HistorialParqueoBus
        SET Motivo=@Motivo
        WHERE HistorialParqueoID=(SELECT MAX(HistorialParqueoID) FROM ops.HistorialParqueoBus WHERE BusID=@BusID);
    COMMIT;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_RegistrarConteoEstacion
    @EstacionID INT,
    @CantidadPasajeros INT,
    @OperadorID INT=NULL,
    @CapacidadEvaluada SMALLINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @CantidadPasajeros < 0 THROW 51130, 'La cantidad de pasajeros no puede ser negativa.', 1;
    IF @CapacidadEvaluada IS NULL
        SELECT @CapacidadEvaluada=CapacidadReferencia FROM ops.Estacion WHERE EstacionID=@EstacionID;
    IF @CapacidadEvaluada IS NULL OR @CapacidadEvaluada<=0
        THROW 51131, 'La estacion no existe o no tiene capacidad valida.', 1;

    BEGIN TRAN;
    INSERT ops.ConteoEstacion(EstacionID,CantidadPasajeros,CapacidadEvaluada,OperadorID)
    VALUES(@EstacionID,@CantidadPasajeros,@CapacidadEvaluada,@OperadorID);
    DECLARE @ConteoID BIGINT=SCOPE_IDENTITY(),
            @Porcentaje DECIMAL(7,2)=ROUND(@CantidadPasajeros*100.0/@CapacidadEvaluada,2);
    IF @Porcentaje>=150
        INSERT ops.AlertaOcupacion(ConteoEstacionID,EstacionID,Porcentaje,RequiereUnidad)
        VALUES(@ConteoID,@EstacionID,@Porcentaje,1);
    COMMIT;

    SELECT @ConteoID AS ConteoEstacionID, @Porcentaje AS Porcentaje,
           CONVERT(BIT,CASE WHEN @Porcentaje>=150 THEN 1 ELSE 0 END) AS AlertaGenerada;
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_RegistrarOcupacionBus
    @BusID INT,
    @EstacionID INT,
    @CantidadPasajeros SMALLINT,
    @ViajeID BIGINT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Capacidad SMALLINT=(SELECT CapacidadMaxima FROM ops.Bus WHERE BusID=@BusID);
    IF @Capacidad IS NULL THROW 51140, 'El bus indicado no existe.', 1;
    IF @CantidadPasajeros<0 OR @CantidadPasajeros>@Capacidad
        THROW 51141, 'La ocupacion debe estar entre cero y la capacidad maxima del bus.', 1;
    DECLARE @Porcentaje DECIMAL(7,2)=ROUND(@CantidadPasajeros*100.0/@Capacidad,2);
    BEGIN TRAN;
    INSERT ops.RegistroOcupacionBus(BusID,EstacionID,ViajeID,CantidadPasajeros,CapacidadEvaluada,PorcentajeOcupacion)
    VALUES(@BusID,@EstacionID,@ViajeID,@CantidadPasajeros,@Capacidad,@Porcentaje);
    DECLARE @RegistroID BIGINT=SCOPE_IDENTITY();
    IF @Porcentaje<25
        INSERT ops.EsperaAdicional(RegistroOcupacionID,MinutosAdicionales) VALUES(@RegistroID,5);
    COMMIT;
    SELECT @RegistroID RegistroOcupacionID,@Porcentaje PorcentajeOcupacion,
           CONVERT(BIT,CASE WHEN @Porcentaje<25 THEN 1 ELSE 0 END) DebeEsperar,
           CASE WHEN @Porcentaje<25 THEN 5 ELSE 0 END MinutosAdicionales;
END;
GO

CREATE OR ALTER PROCEDURE fin.sp_RegistrarMovimientoTarjeta
    @TarjetaID BIGINT,
    @Tipo CHAR(1),
    @Monto DECIMAL(12,2),
    @Referencia VARCHAR(80),
    @EstacionID INT=NULL,
    @UsuarioID INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @Tipo NOT IN ('R','P') THROW 51150, 'Tipo invalido: R=recarga, P=pago.', 1;
    IF @Monto<=0 THROW 51151, 'El monto debe ser mayor que cero.', 1;

    BEGIN TRY
        BEGIN TRAN;
        DECLARE @SaldoAnterior DECIMAL(12,2), @Estado VARCHAR(20), @Vence DATE;
        SELECT @SaldoAnterior=Saldo,@Estado=Estado,@Vence=FechaVencimiento
        FROM fin.TarjetaAcceso WITH (UPDLOCK,HOLDLOCK)
        WHERE TarjetaID=@TarjetaID;
        IF @SaldoAnterior IS NULL THROW 51152, 'La tarjeta indicada no existe.', 1;
        IF @Estado<>'ACTIVA' OR (@Vence IS NOT NULL AND @Vence<CAST(SYSUTCDATETIME() AS DATE))
            THROW 51153, 'La tarjeta no esta activa o se encuentra vencida.', 1;
        IF @Tipo='P' AND @SaldoAnterior<@Monto THROW 51154, 'Saldo insuficiente para realizar el pago.', 1;
        IF EXISTS (SELECT 1 FROM fin.TransaccionTarjeta WHERE Referencia=@Referencia)
            THROW 51155, 'La referencia de la transaccion ya fue utilizada.', 1;

        DECLARE @SaldoNuevo DECIMAL(12,2)=CASE WHEN @Tipo='R' THEN @SaldoAnterior+@Monto ELSE @SaldoAnterior-@Monto END;
        EXEC sys.sp_set_session_context @key=N'MovimientoTarjetaAutorizado',@value=1;
        UPDATE fin.TarjetaAcceso SET Saldo=@SaldoNuevo WHERE TarjetaID=@TarjetaID;
        INSERT fin.TransaccionTarjeta(TarjetaID,EstacionID,Tipo,Monto,SaldoAnterior,SaldoNuevo,Referencia,UsuarioID)
        VALUES(@TarjetaID,@EstacionID,@Tipo,@Monto,@SaldoAnterior,@SaldoNuevo,@Referencia,@UsuarioID);
        DECLARE @TransaccionID BIGINT=SCOPE_IDENTITY();
        EXEC sys.sp_set_session_context @key=N'MovimientoTarjetaAutorizado',@value=NULL;
        COMMIT;
        SELECT @TransaccionID TransaccionID,@SaldoNuevo SaldoActual;
    END TRY
    BEGIN CATCH
        EXEC sys.sp_set_session_context @key=N'MovimientoTarjetaAutorizado',@value=NULL;
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ops.sp_ValidarIntegridadOperativa
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 'LINEA_SIN_ESTACIONES' Problema,l.LineaID Referencia,l.Codigo Detalle
    FROM ops.Linea l WHERE l.Estado='A' AND NOT EXISTS(SELECT 1 FROM ops.LineaEstacion le WHERE le.LineaID=l.LineaID)
    UNION ALL
    SELECT 'ESTACION_SIN_LINEA',e.EstacionID,e.Codigo FROM ops.Estacion e
    WHERE e.Estado='A' AND NOT EXISTS(SELECT 1 FROM ops.LineaEstacion le WHERE le.EstacionID=e.EstacionID)
    UNION ALL
    SELECT 'ACCESO_SIN_GUARDIA',a.AccesoID,a.Codigo FROM ops.Acceso a
    WHERE a.Estado='A' AND NOT EXISTS(SELECT 1 FROM ops.AsignacionGuardiaAcceso x WHERE x.AccesoID=a.AccesoID AND x.FechaFin IS NULL)
    UNION ALL
    SELECT 'ESTACION_SIN_OPERADOR',e.EstacionID,e.Codigo FROM ops.Estacion e
    WHERE e.Estado='A' AND NOT EXISTS(SELECT 1 FROM ops.AsignacionOperadorEstacion x WHERE x.EstacionID=e.EstacionID AND x.FechaFin IS NULL)
    UNION ALL
    SELECT 'LINEA_FUERA_LIMITE_BUSES',l.LineaID,l.Codigo FROM ops.Linea l
    CROSS APPLY(SELECT COUNT(*) n FROM ops.LineaEstacion WHERE LineaID=l.LineaID) e
    CROSS APPLY(SELECT COUNT(*) n FROM ops.LineaBus WHERE LineaID=l.LineaID) b
    WHERE l.Estado='A' AND (b.n<e.n OR b.n>2*e.n);
END;
GO

/*=============================================================================
  10. VISTAS Y CONSULTAS PARA REPORTES REQUERIDOS
=============================================================================*/
CREATE OR ALTER VIEW rep.vw_Estaciones
AS
SELECT e.EstacionID,e.Codigo,e.Nombre,e.Direccion,e.Latitud,e.Longitud,
       e.CapacidadReferencia,e.Estado,m.Nombre Municipalidad,
       COUNT(DISTINCT le.LineaID) CantidadLineas,
       COUNT(DISTINCT a.AccesoID) CantidadAccesos
FROM ops.Estacion e
JOIN cat.Municipalidad m ON m.MunicipalidadID=e.MunicipalidadID
LEFT JOIN ops.LineaEstacion le ON le.EstacionID=e.EstacionID
LEFT JOIN ops.Acceso a ON a.EstacionID=e.EstacionID
GROUP BY e.EstacionID,e.Codigo,e.Nombre,e.Direccion,e.Latitud,e.Longitud,
         e.CapacidadReferencia,e.Estado,m.Nombre;
GO

CREATE OR ALTER VIEW rep.vw_Lineas
AS
SELECT l.LineaID,l.Codigo,l.Nombre,l.Estado,m.Nombre Municipalidad,
       e.CantidadEstaciones,b.CantidadBuses,t.DistanciaTotalKm
FROM ops.Linea l
JOIN cat.Municipalidad m ON m.MunicipalidadID=l.MunicipalidadID
OUTER APPLY
(
    SELECT COUNT(*) CantidadEstaciones
    FROM ops.LineaEstacion le WHERE le.LineaID=l.LineaID
) e
OUTER APPLY
(
    SELECT COUNT(*) CantidadBuses
    FROM ops.LineaBus lb WHERE lb.LineaID=l.LineaID
) b
OUTER APPLY
(
    SELECT COALESCE(SUM(tl.DistanciaKm),0) DistanciaTotalKm
    FROM ops.TramoLinea tl WHERE tl.LineaID=l.LineaID
) t;
GO

CREATE OR ALTER VIEW rep.vw_BusesPorLinea
AS
SELECT l.LineaID,l.Codigo CodigoLinea,l.Nombre Linea,
       b.BusID,b.CodigoInterno,b.Placa,b.Marca,b.Modelo,b.CapacidadMaxima,b.Estado,
       p.Codigo CodigoParqueo,p.Nombre Parqueo,e.Nombre EstacionParqueo
FROM ops.Linea l
JOIN ops.LineaBus lb ON lb.LineaID=l.LineaID
JOIN ops.Bus b ON b.BusID=lb.BusID
JOIN ops.Parqueo p ON p.ParqueoID=b.ParqueoID
JOIN ops.Estacion e ON e.EstacionID=p.EstacionID;
GO

CREATE OR ALTER VIEW rep.vw_EstacionesPorLinea
AS
SELECT l.LineaID,l.Codigo CodigoLinea,l.Nombre Linea,le.Orden,
       e.EstacionID,e.Codigo CodigoEstacion,e.Nombre Estacion,
       t.DistanciaKm DistanciaSiguienteKm
FROM ops.Linea l
JOIN ops.LineaEstacion le ON le.LineaID=l.LineaID
JOIN ops.Estacion e ON e.EstacionID=le.EstacionID
LEFT JOIN ops.TramoLinea t ON t.LineaID=le.LineaID AND t.EstacionOrigenID=le.EstacionID;
GO

CREATE OR ALTER VIEW rep.vw_AccesosPorLinea
AS
SELECT l.LineaID,l.Codigo CodigoLinea,l.Nombre Linea,le.Orden,
       e.EstacionID,e.Nombre Estacion,a.AccesoID,a.Codigo CodigoAcceso,a.Nombre Acceso,a.TipoAcceso,a.Estado
FROM ops.Linea l
JOIN ops.LineaEstacion le ON le.LineaID=l.LineaID
JOIN ops.Estacion e ON e.EstacionID=le.EstacionID
JOIN ops.Acceso a ON a.EstacionID=e.EstacionID;
GO

CREATE OR ALTER VIEW rep.vw_AlertasPendientes
AS
SELECT a.AlertaID,a.FechaGeneracion,e.Codigo CodigoEstacion,e.Nombre Estacion,
       c.CantidadPasajeros,c.CapacidadEvaluada,a.Porcentaje,a.RequiereUnidad,a.Estado
FROM ops.AlertaOcupacion a
JOIN ops.ConteoEstacion c ON c.ConteoEstacionID=a.ConteoEstacionID
JOIN ops.Estacion e ON e.EstacionID=a.EstacionID
WHERE a.Estado='PENDIENTE';
GO

/* Consultas que deben documentarse y utilizarse desde la aplicacion web:
   SELECT * FROM rep.vw_Estaciones ORDER BY Nombre;
   SELECT * FROM rep.vw_Lineas ORDER BY Codigo;
   SELECT * FROM rep.vw_BusesPorLinea ORDER BY CodigoLinea, CodigoInterno;
   SELECT * FROM rep.vw_EstacionesPorLinea WHERE LineaID=@LineaID ORDER BY Orden;
   SELECT * FROM rep.vw_AccesosPorLinea WHERE LineaID=@LineaID ORDER BY Orden, CodigoAcceso;
*/

/*=============================================================================
  11. DATOS INICIALES DE SEGURIDAD
=============================================================================*/
INSERT seg.Rol(Nombre,Descripcion)
SELECT v.Nombre,v.Descripcion
FROM (VALUES
 (N'Administrador',N'Control total de configuracion, usuarios y datos.'),
 (N'Supervisor',N'Consulta operativa, alertas y reportes.'),
 (N'Operador de estacion',N'Gestion de funciones de su estacion asignada.'),
 (N'Administrativo',N'Gestion autorizada de flota y personal.'),
 (N'Auditor',N'Consulta de reportes y bitacora sin modificacion.')
)v(Nombre,Descripcion)
WHERE NOT EXISTS(SELECT 1 FROM seg.Rol r WHERE r.Nombre=v.Nombre);
GO

INSERT seg.Permiso(Codigo,Descripcion)
SELECT v.Codigo,v.Descripcion
FROM (VALUES
 ('LINEAS_VER',N'Consultar lineas y recorridos'),('LINEAS_EDITAR',N'Administrar lineas'),
 ('ESTACIONES_VER',N'Consultar estaciones'),('ESTACIONES_EDITAR',N'Administrar estaciones y accesos'),
 ('FLOTA_VER',N'Consultar buses y parqueos'),('FLOTA_EDITAR',N'Administrar buses y asignaciones'),
 ('PERSONAL_VER',N'Consultar personal'),('PERSONAL_EDITAR',N'Administrar personal'),
 ('PAGOS_OPERAR',N'Realizar recargas y pagos'),('ALERTAS_GESTIONAR',N'Atender alertas operativas'),
 ('REPORTES_VER',N'Consultar reportes'),('USUARIOS_EDITAR',N'Administrar usuarios y roles'),
 ('AUDITORIA_VER',N'Consultar historial de operaciones')
)v(Codigo,Descripcion)
WHERE NOT EXISTS(SELECT 1 FROM seg.Permiso p WHERE p.Codigo=v.Codigo);
GO

/* El administrador recibe todos los permisos. */
INSERT seg.RolPermiso(RolID,PermisoID)
SELECT r.RolID,p.PermisoID FROM seg.Rol r CROSS JOIN seg.Permiso p
WHERE r.Nombre=N'Administrador'
  AND NOT EXISTS(SELECT 1 FROM seg.RolPermiso rp WHERE rp.RolID=r.RolID AND rp.PermisoID=p.PermisoID);
GO

/* Permisos iniciales para los demas perfiles. Pueden ajustarse desde la aplicacion. */
INSERT seg.RolPermiso(RolID,PermisoID)
SELECT r.RolID,p.PermisoID
FROM seg.Rol r
JOIN seg.Permiso p ON
       (r.Nombre=N'Supervisor' AND p.Codigo IN ('LINEAS_VER','ESTACIONES_VER','FLOTA_VER','PERSONAL_VER','ALERTAS_GESTIONAR','REPORTES_VER'))
    OR (r.Nombre=N'Operador de estacion' AND p.Codigo IN ('LINEAS_VER','ESTACIONES_VER','FLOTA_VER','PAGOS_OPERAR','ALERTAS_GESTIONAR','REPORTES_VER'))
    OR (r.Nombre=N'Administrativo' AND p.Codigo IN ('LINEAS_VER','ESTACIONES_VER','FLOTA_VER','FLOTA_EDITAR','PERSONAL_VER','PERSONAL_EDITAR','REPORTES_VER'))
    OR (r.Nombre=N'Auditor' AND p.Codigo IN ('LINEAS_VER','ESTACIONES_VER','FLOTA_VER','REPORTES_VER','AUDITORIA_VER'))
WHERE NOT EXISTS
      (SELECT 1 FROM seg.RolPermiso rp WHERE rp.RolID=r.RolID AND rp.PermisoID=p.PermisoID);
GO

/*=============================================================================
  12. VERIFICACION FINAL Y RESPALDO
=============================================================================*/
PRINT N'Base de datos TransmetroGestionDB creada correctamente.';
PRINT N'Ejecute: EXEC ops.sp_ValidarIntegridadOperativa;';
GO

/* RESPALDO PARA SQL SERVER LOCAL (ajustar una ruta segura y permisos):
BACKUP DATABASE TransmetroGestionDB
TO DISK = 'D:\Respaldos\TransmetroGestionDB_FULL.bak'
WITH COMPRESSION, CHECKSUM, INIT, NAME = 'Respaldo completo TransmetroGestionDB';

RESTORE VERIFYONLY
FROM DISK = 'D:\Respaldos\TransmetroGestionDB_FULL.bak'
WITH CHECKSUM;

En Azure SQL Database, configurar retencion y recuperacion desde el portal de
Azure; BACKUP DATABASE a disco local no aplica al servicio administrado.
*/
