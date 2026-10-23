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
