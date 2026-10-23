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

/* V3: mantenimiento sin borrar itinerarios, y conteos atribuidos a una línea. */
IF COL_LENGTH(N'ops.VisitaEstacionViaje',N'OmitidaMantenimiento') IS NULL
 ALTER TABLE ops.VisitaEstacionViaje ADD OmitidaMantenimiento BIT NOT NULL CONSTRAINT DF_Visita_Omitida DEFAULT(0);
IF COL_LENGTH(N'ops.ConteoEstacion',N'LineaID') IS NULL
 ALTER TABLE ops.ConteoEstacion ADD LineaID INT NULL CONSTRAINT FK_Conteo_Linea REFERENCES ops.Linea(LineaID);
GO
-- Sólo se atribuyen datos anteriores cuando la estación pertenece a una única línea.
UPDATE c SET LineaID=u.LineaID FROM ops.ConteoEstacion c
JOIN (SELECT EstacionID,MIN(LineaID) LineaID FROM ops.LineaEstacion GROUP BY EstacionID HAVING COUNT(*)=1)u ON u.EstacionID=c.EstacionID
WHERE c.LineaID IS NULL;
UPDATE v SET OmitidaMantenimiento=1 FROM ops.VisitaEstacionViaje v
JOIN ops.Viaje viaje ON viaje.ViajeID=v.ViajeID JOIN ops.Estacion e ON e.EstacionID=v.EstacionID
WHERE e.Estado='I' AND viaje.Estado IN('EN_CURSO','PROGRAMADO') AND v.LlegadaReal IS NULL;
GO
CREATE OR ALTER TRIGGER ops.tr_VisitaEstacion_ValidarRuta
ON ops.VisitaEstacionViaje AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 -- La ruta se valida al crear una visita. Las fechas posteriores usan el itinerario del viaje,
 -- aunque se haya editado la asignación actual de la estación.
 IF EXISTS(SELECT 1 FROM inserted i LEFT JOIN deleted d ON d.ViajeID=i.ViajeID AND d.EstacionID=i.EstacionID
 JOIN ops.Viaje v ON v.ViajeID=i.ViajeID
 WHERE d.ViajeID IS NULL AND NOT EXISTS(SELECT 1 FROM ops.LineaEstacion le
 WHERE le.LineaID=v.LineaID AND le.EstacionID=i.EstacionID AND le.Orden=i.OrdenVisita))
 THROW 51010,'La nueva visita debe respetar la ruta y el orden de la linea.',1;
 IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.ViajeID=i.ViajeID AND d.EstacionID=i.EstacionID WHERE i.OrdenVisita<>d.OrdenVisita)
 THROW 51017,'No se puede reordenar una visita existente: el viaje conserva su itinerario.',1;
END;
GO
CREATE OR ALTER TRIGGER ops.tr_Estacion_Mantenimiento
ON ops.Estacion AFTER UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF NOT UPDATE(Estado) RETURN;
 UPDATE parada SET OmitidaMantenimiento=1
 FROM ops.VisitaEstacionViaje parada JOIN ops.Viaje viaje ON viaje.ViajeID=parada.ViajeID
 JOIN inserted i ON i.EstacionID=parada.EstacionID JOIN deleted d ON d.EstacionID=i.EstacionID
 WHERE i.Estado='I' AND d.Estado<>'I' AND viaje.Estado IN('EN_CURSO','PROGRAMADO') AND parada.LlegadaReal IS NULL;
 UPDATE parada SET OmitidaMantenimiento=0
 FROM ops.VisitaEstacionViaje parada JOIN ops.Viaje viaje ON viaje.ViajeID=parada.ViajeID
 JOIN inserted i ON i.EstacionID=parada.EstacionID JOIN deleted d ON d.EstacionID=i.EstacionID
 WHERE i.Estado='A' AND d.Estado<>'A' AND viaje.Estado IN('EN_CURSO','PROGRAMADO') AND parada.LlegadaReal IS NULL
 AND parada.OrdenVisita>COALESCE((SELECT MAX(v.OrdenVisita) FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=parada.ViajeID AND v.LlegadaReal IS NOT NULL),0);
 -- Si desaparece la última parada pendiente, termina el viaje; sin ninguna llegada se cancela.
 UPDATE viaje SET Estado=CASE WHEN EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.LlegadaReal IS NOT NULL) THEN 'FINALIZADO' ELSE 'CANCELADO' END,
 FechaLlegada=CASE WHEN EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.LlegadaReal IS NOT NULL) THEN
 CASE WHEN SYSUTCDATETIME()<viaje.FechaSalida THEN viaje.FechaSalida ELSE SYSUTCDATETIME() END ELSE NULL END
 FROM ops.Viaje viaje
 WHERE viaje.Estado IN('EN_CURSO','PROGRAMADO')
 AND EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v JOIN inserted i ON i.EstacionID=v.EstacionID WHERE v.ViajeID=viaje.ViajeID AND i.Estado='I')
 AND NOT EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.OmitidaMantenimiento=0 AND v.SalidaReal IS NULL);
 UPDATE b SET Estado='DISPONIBLE' FROM ops.Bus b
 WHERE b.Estado='EN_RUTA' AND NOT EXISTS(SELECT 1 FROM ops.Viaje v WHERE v.BusID=b.BusID AND v.Estado='EN_CURSO')
 AND EXISTS(SELECT 1 FROM ops.Viaje v JOIN ops.VisitaEstacionViaje parada ON parada.ViajeID=v.ViajeID
 JOIN inserted i ON i.EstacionID=parada.EstacionID WHERE v.BusID=b.BusID AND i.Estado='I');
END;
GO
-- Corrige recorridos que ya no tenían ninguna parada disponible antes de instalar V3.
UPDATE viaje SET Estado=CASE WHEN EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.LlegadaReal IS NOT NULL) THEN 'FINALIZADO' ELSE 'CANCELADO' END,
FechaLlegada=CASE WHEN EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.LlegadaReal IS NOT NULL) THEN
 CASE WHEN SYSUTCDATETIME()<viaje.FechaSalida THEN viaje.FechaSalida ELSE SYSUTCDATETIME() END ELSE NULL END
FROM ops.Viaje viaje WHERE viaje.Estado IN('EN_CURSO','PROGRAMADO')
AND EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.OmitidaMantenimiento=1)
AND NOT EXISTS(SELECT 1 FROM ops.VisitaEstacionViaje v WHERE v.ViajeID=viaje.ViajeID AND v.OmitidaMantenimiento=0 AND v.SalidaReal IS NULL);
UPDATE b SET Estado='DISPONIBLE' FROM ops.Bus b WHERE b.Estado='EN_RUTA'
AND NOT EXISTS(SELECT 1 FROM ops.Viaje v WHERE v.BusID=b.BusID AND v.Estado='EN_CURSO')
AND EXISTS(SELECT 1 FROM ops.Viaje v JOIN ops.VisitaEstacionViaje parada ON parada.ViajeID=v.ViajeID WHERE v.BusID=b.BusID AND parada.OmitidaMantenimiento=1);
GO
CREATE OR ALTER PROCEDURE ops.sp_RegistrarConteoEstacion
    @EstacionID INT,
    @CantidadPasajeros INT,
    @OperadorID INT=NULL,
    @CapacidadEvaluada SMALLINT=NULL,
    @LineaID INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @CantidadPasajeros < 0 THROW 51130, 'La cantidad de pasajeros no puede ser negativa.', 1;
    IF @CapacidadEvaluada IS NULL
        SELECT @CapacidadEvaluada=CapacidadReferencia FROM ops.Estacion WHERE EstacionID=@EstacionID;
    IF @CapacidadEvaluada IS NULL OR @CapacidadEvaluada<=0
        THROW 51131, 'La estacion no existe o no tiene capacidad valida.', 1;

    IF @LineaID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ops.LineaEstacion WHERE LineaID=@LineaID AND EstacionID=@EstacionID)
       AND NOT EXISTS(SELECT 1 FROM ops.Viaje v JOIN ops.VisitaEstacionViaje p ON p.ViajeID=v.ViajeID WHERE v.LineaID=@LineaID AND p.EstacionID=@EstacionID AND v.Estado='EN_CURSO')
        THROW 51132,'La estacion no pertenece a la linea ni a un recorrido vigente de ella.',1;
    BEGIN TRAN;
    INSERT ops.ConteoEstacion(EstacionID,CantidadPasajeros,CapacidadEvaluada,OperadorID,LineaID)
    VALUES(@EstacionID,@CantidadPasajeros,@CapacidadEvaluada,@OperadorID,@LineaID);
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

PRINT N'Actualización V3 completada.';
GO
