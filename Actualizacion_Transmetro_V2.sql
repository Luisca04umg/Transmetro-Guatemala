USE TransmetroGestionDB;
GO
-- Actualización aditiva: no elimina tablas ni datos existentes.
IF OBJECT_ID(N'ops.AsignacionPilotoBus', N'U') IS NULL
BEGIN
    CREATE TABLE ops.AsignacionPilotoBus
    (
        AsignacionID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AsignacionPilotoBus PRIMARY KEY,
        BusID INT NOT NULL CONSTRAINT FK_AsignacionPilotoBus_Bus REFERENCES ops.Bus(BusID),
        PilotoID INT NOT NULL CONSTRAINT FK_AsignacionPilotoBus_Piloto REFERENCES ops.Piloto(PilotoID),
        FechaInicio DATETIME2 NOT NULL CONSTRAINT DF_AsignacionPilotoBus_Inicio DEFAULT SYSUTCDATETIME(),
        FechaFin DATETIME2 NULL,
        CONSTRAINT CK_AsignacionPilotoBus_Fechas CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio)
    );
    CREATE UNIQUE INDEX UX_AsignacionPilotoBus_BusActivo ON ops.AsignacionPilotoBus(BusID) WHERE FechaFin IS NULL;
    CREATE UNIQUE INDEX UX_AsignacionPilotoBus_PilotoActivo ON ops.AsignacionPilotoBus(PilotoID) WHERE FechaFin IS NULL;
END;
GO

-- Corrección de usuarios: NULL no representa un operador asignado.
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id=OBJECT_ID(N'seg.Usuario') AND name=N'UQ_Usuario_Operador')
    ALTER TABLE seg.Usuario DROP CONSTRAINT UQ_Usuario_Operador;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'seg.Usuario') AND name=N'UX_Usuario_Operador_NoNulo')
    CREATE UNIQUE INDEX UX_Usuario_Operador_NoNulo ON seg.Usuario(OperadorID) WHERE OperadorID IS NOT NULL;
GO
IF COL_LENGTH(N'fin.TitularTarjeta', N'DPI') IS NULL
    ALTER TABLE fin.TitularTarjeta ADD DPI VARCHAR(9) NULL;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'fin.TitularTarjeta') AND name=N'CK_Titular_DPI')
    ALTER TABLE fin.TitularTarjeta ADD CONSTRAINT CK_Titular_DPI CHECK
        (DPI IS NULL OR (LEN(DPI) IN (8,9) AND DPI NOT LIKE '%[^0-9]%' COLLATE Latin1_General_100_BIN2 AND DATALENGTH(DPI)=LEN(DPI)));
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'fin.TitularTarjeta') AND name=N'UX_Titular_DPI')
    CREATE UNIQUE INDEX UX_Titular_DPI ON fin.TitularTarjeta(DPI) WHERE DPI IS NOT NULL;
GO
-- Tarjetas sin caducidad. No reactiva las tarjetas que estaban vencidas.
UPDATE fin.TarjetaAcceso SET FechaVencimiento=NULL, Estado=CASE WHEN Estado='VENCIDA' THEN 'INACTIVA' ELSE Estado END
WHERE FechaVencimiento IS NOT NULL OR Estado='VENCIDA';
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(N'fin.TarjetaAcceso') AND name=N'CK_Tarjeta_Estado')
    ALTER TABLE fin.TarjetaAcceso DROP CONSTRAINT CK_Tarjeta_Estado;
ALTER TABLE fin.TarjetaAcceso ADD CONSTRAINT CK_Tarjeta_Estado CHECK (Estado IN ('ACTIVA','BLOQUEADA','INACTIVA'));
GO
IF OBJECT_ID(N'ops.RegistroParadaViaje',N'U') IS NULL
BEGIN
 CREATE TABLE ops.RegistroParadaViaje
 (
    RegistroParadaID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ViajeID BIGINT NOT NULL,
    EstacionID INT NOT NULL,
    PasajerosAntes SMALLINT NOT NULL,
    Suben SMALLINT NOT NULL,
    Bajan SMALLINT NOT NULL,
    PasajerosDespues SMALLINT NOT NULL,
    EsperanEstacion INT NOT NULL,
    FechaRegistro DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_RegistroParada_Visita FOREIGN KEY(ViajeID,EstacionID) REFERENCES ops.VisitaEstacionViaje(ViajeID,EstacionID),
    CONSTRAINT UQ_RegistroParada_Visita UNIQUE(ViajeID,EstacionID),
    CONSTRAINT CK_RegistroParada_Conteos CHECK(PasajerosAntes>=0 AND Suben>=0 AND Bajan>=0 AND Bajan<=PasajerosAntes AND PasajerosDespues=PasajerosAntes-Bajan+Suben AND EsperanEstacion>=0)
 );
END;
GO
IF OBJECT_ID(N'fin.PaseLineaTarjeta',N'U') IS NULL
BEGIN
 CREATE TABLE fin.PaseLineaTarjeta
 (
    PaseID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TarjetaID BIGINT NOT NULL REFERENCES fin.TarjetaAcceso(TarjetaID),
    LineaID INT NOT NULL REFERENCES ops.Linea(LineaID),
    EstacionID INT NOT NULL REFERENCES ops.Estacion(EstacionID),
    TransaccionID BIGINT NOT NULL REFERENCES fin.TransaccionTarjeta(TransaccionID),
    FechaInicio DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    FechaFin DATETIME2(0) NULL,
    CONSTRAINT UQ_Pase_Transaccion UNIQUE(TransaccionID),
    CONSTRAINT CK_Pase_Fechas CHECK(FechaFin IS NULL OR FechaFin>=FechaInicio)
 );
 CREATE UNIQUE INDEX UX_Pase_TarjetaActivo ON fin.PaseLineaTarjeta(TarjetaID) WHERE FechaFin IS NULL;
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
    IF @ViajeID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ops.Viaje WHERE ViajeID=@ViajeID AND BusID=@BusID)
        THROW 51142, 'El recorrido no existe o no corresponde al bus.', 1;
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE EstacionID=@EstacionID)
        THROW 51143, 'La estacion indicada no existe.', 1;
    IF @ViajeID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ops.VisitaEstacionViaje WHERE ViajeID=@ViajeID AND EstacionID=@EstacionID)
        THROW 51144, 'La estacion no pertenece al recorrido.', 1;
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

PRINT N'Actualización V2 completada. Instala ahora el código V2.';
GO
