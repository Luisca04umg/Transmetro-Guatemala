/* DATOS FICTICIOS PARA PRUEBAS. No representan personal, distancias, horarios ni flota reales.
   Antes: ejecutar Actualizacion_Transmetro_V2.sql y la carga geográfica suministrada.
   Reejecutable: usa prefijos DEMO- y referencias únicas; no elimina los registros actuales.
   Sólo completar los TiempoMinuto NULL se hace con minutos ficticios (3); no cambia valores existentes.
   Credenciales de prueba: demo.admin / demo.operador / demo.auditor — TransmetroDemo!2026. */
USE TransmetroGestionDB;
GO
SET XACT_ABORT ON;
IF COL_LENGTH(N'fin.TitularTarjeta',N'DPI') IS NULL OR OBJECT_ID(N'ops.RegistroParadaViaje') IS NULL
    THROW 51200,'Ejecute primero Actualizacion_Transmetro_V2.sql.',1;
IF NOT EXISTS(SELECT 1 FROM ops.LineaEstacion)
    THROW 51201,'Ejecute primero Carga_Transmetro_2025.sql para cargar lineas y estaciones.',1;
BEGIN TRY
BEGIN TRAN;
DECLARE @Ahora DATETIME2(0)=SYSUTCDATETIME();
-- Municipalidad ficticia con datos completos, sin alterar la municipalidad real.
IF NOT EXISTS(SELECT 1 FROM cat.Municipalidad WHERE Codigo='DEMO-MUNI')
 INSERT cat.Municipalidad(Codigo,Nombre,Departamento,Telefono,Correo,Direccion,Activa,FechaCreacion)
 VALUES('DEMO-MUNI',N'Municipalidad de prueba',N'Guatemala','55550000','municipalidad@demo.example',N'Dirección ficticia de prueba',1,@Ahora);
-- Parqueos de prueba por estación; su capacidad incluye flota de todas sus líneas.
INSERT ops.Parqueo(EstacionID,Codigo,Nombre,CapacidadBuses,Activo,FechaCreacion)
SELECT e.EstacionID,CONCAT('DEMO-P-',e.EstacionID),LEFT(CONCAT(N'Parqueo de prueba ',e.Nombre),120),1000,1,@Ahora
FROM ops.Estacion e WHERE NOT EXISTS(SELECT 1 FROM ops.Parqueo p WHERE p.Codigo=CONCAT('DEMO-P-',e.EstacionID));
-- Cuatro tipos de acceso, con su guardia específico.
INSERT ops.Acceso(EstacionID,Codigo,Nombre,Descripcion,TipoAcceso,Estado,FechaCreacion)
SELECT e.EstacionID,CONCAT('DEMO-A-',e.EstacionID,'-',t.Sufijo),CONCAT(t.Nombre,N' · ',e.Codigo),N'Entrada ficticia para probar asignación de guardias.',t.Tipo,'P',@Ahora
FROM ops.Estacion e CROSS JOIN(VALUES('P','PEATONAL',N'Entrada peatonal'),('V','VEHICULAR',N'Ingreso vehicular'),('M','MIXTO',N'Acceso mixto'),('E','EMERGENCIA',N'Salida de emergencia'))t(Sufijo,Tipo,Nombre)
WHERE e.Estado<>'I' AND NOT EXISTS(SELECT 1 FROM ops.Acceso a WHERE a.EstacionID=e.EstacionID AND a.Codigo=CONCAT('DEMO-A-',e.EstacionID,'-',t.Sufijo));
INSERT ops.Guardia(CodigoEmpleado,Nombres,Apellidos,Telefono,Empresa,Activo,FechaRegistro)
SELECT CONCAT('DEMO-G-',a.AccesoID),N'Guardia de prueba',CONCAT(N'Acceso ',a.AccesoID),'55550001',N'Seguridad demostración',1,@Ahora
FROM ops.Acceso a WHERE a.Codigo LIKE 'DEMO-A-%' AND NOT EXISTS(SELECT 1 FROM ops.Guardia g WHERE g.CodigoEmpleado=CONCAT('DEMO-G-',a.AccesoID));
INSERT ops.AsignacionGuardiaAcceso(GuardiaID,AccesoID,FechaInicio,FechaFin,Turno)
SELECT g.GuardiaID,a.AccesoID,DATEADD(day,-7,@Ahora),NULL,CASE a.AccesoID%3 WHEN 0 THEN 'DIURNO' WHEN 1 THEN 'NOCTURNO' ELSE 'MIXTO' END
FROM ops.Acceso a JOIN ops.Guardia g ON g.CodigoEmpleado=CONCAT('DEMO-G-',a.AccesoID)
WHERE a.Codigo LIKE 'DEMO-A-%' AND NOT EXISTS(SELECT 1 FROM ops.AsignacionGuardiaAcceso x WHERE x.GuardiaID=g.GuardiaID AND x.FechaFin IS NULL);
UPDATE a SET Estado='A' FROM ops.Acceso a WHERE a.Codigo LIKE 'DEMO-A-%' AND a.Estado='P'
AND EXISTS(SELECT 1 FROM ops.AsignacionGuardiaAcceso x WHERE x.AccesoID=a.AccesoID AND x.FechaFin IS NULL);
INSERT ops.Operador(CodigoEmpleado,Nombres,Apellidos,Telefono,Correo,Activo,FechaRegistro)
SELECT CONCAT('DEMO-O-',e.EstacionID),N'Operador de prueba',CONCAT(N'Estación ',e.EstacionID),'55550002',CONCAT('operador',e.EstacionID,'@demo.example'),1,@Ahora
FROM ops.Estacion e WHERE e.Estado<>'I' AND NOT EXISTS(SELECT 1 FROM ops.Operador o WHERE o.CodigoEmpleado=CONCAT('DEMO-O-',e.EstacionID));
INSERT ops.AsignacionOperadorEstacion(OperadorID,EstacionID,FechaInicio,FechaFin)
SELECT o.OperadorID,e.EstacionID,DATEADD(day,-7,@Ahora),NULL
FROM ops.Estacion e JOIN ops.Operador o ON o.CodigoEmpleado=CONCAT('DEMO-O-',e.EstacionID)
WHERE NOT EXISTS(SELECT 1 FROM ops.AsignacionOperadorEstacion x WHERE (x.EstacionID=e.EstacionID OR x.OperadorID=o.OperadorID) AND x.FechaFin IS NULL);
-- Distancias de prueba y tiempos: no son datos oficiales.
INSERT ops.TramoLinea(LineaID,EstacionOrigenID,EstacionDestinoID,DistanciaKm,FechaActualizacion)
SELECT a.LineaID,a.EstacionID,b.EstacionID,0.750,@Ahora
FROM ops.LineaEstacion a JOIN ops.LineaEstacion b ON b.LineaID=a.LineaID AND b.Orden=a.Orden+1
WHERE NOT EXISTS(SELECT 1 FROM ops.TramoLinea t WHERE t.LineaID=a.LineaID AND t.EstacionOrigenID=a.EstacionID);
UPDATE ops.LineaEstacion SET TiempoMinuto=CASE WHEN Orden=1 THEN 0 ELSE 3 END WHERE TiempoMinuto IS NULL;
-- Flota mínima que falta por línea; evita sobrepasar el doble de estaciones.
;WITH R AS(SELECT le.LineaID,le.Orden,ROW_NUMBER()OVER(PARTITION BY le.LineaID ORDER BY le.Orden) N,
COUNT(*)OVER(PARTITION BY le.LineaID) CantEst FROM ops.LineaEstacion le)
SELECT r.LineaID,r.N,firstStation.EstacionID INTO #Flota
FROM R r JOIN ops.Linea l ON l.LineaID=r.LineaID
CROSS APPLY(SELECT COUNT(*) C FROM ops.LineaBus b WHERE b.LineaID=r.LineaID)actual
CROSS APPLY(SELECT TOP(1) EstacionID FROM ops.LineaEstacion WHERE LineaID=r.LineaID ORDER BY Orden)firstStation
WHERE l.Estado<>'I' AND r.N<=r.CantEst-actual.C;
INSERT ops.Bus(ParqueoID,CodigoInterno,Placa,Marca,Modelo,Anio,CapacidadMaxima,Estado,FechaRegistro)
SELECT p.ParqueoID,CONCAT('DEMO-L',f.LineaID,'-',f.N),CONCAT('D',f.LineaID,'-',f.N),N'Marca de prueba',N'Unidad de demostración',2025,80,'DISPONIBLE',@Ahora
FROM #Flota f JOIN ops.Parqueo p ON p.Codigo=CONCAT('DEMO-P-',f.EstacionID)
WHERE NOT EXISTS(SELECT 1 FROM ops.Bus b WHERE b.CodigoInterno=CONCAT('DEMO-L',f.LineaID,'-',f.N));
INSERT ops.LineaBus(BusID,LineaID,FechaAsignacion)
SELECT b.BusID,f.LineaID,@Ahora FROM #Flota f JOIN ops.Bus b ON b.CodigoInterno=CONCAT('DEMO-L',f.LineaID,'-',f.N)
WHERE NOT EXISTS(SELECT 1 FROM ops.LineaBus lb WHERE lb.BusID=b.BusID);
DROP TABLE #Flota;
-- Dos unidades adicionales sin línea, una disponible y otra en mantenimiento.
INSERT ops.Bus(ParqueoID,CodigoInterno,Placa,Marca,Modelo,Anio,CapacidadMaxima,Estado,FechaRegistro)
SELECT p.ParqueoID,v.Codigo,v.Placa,N'Marca de prueba',N'Reserva demo',2024,60,v.Estado,@Ahora
FROM (VALUES('DEMO-RESERVA','D-RESERVA','DISPONIBLE'),('DEMO-TALLER','D-TALLER','MANTENIMIENTO'))v(Codigo,Placa,Estado)
CROSS APPLY(SELECT TOP(1) ParqueoID FROM ops.Parqueo WHERE Codigo LIKE 'DEMO-P-%' ORDER BY ParqueoID)p
WHERE NOT EXISTS(SELECT 1 FROM ops.Bus b WHERE b.CodigoInterno=v.Codigo);
INSERT ops.Piloto(CodigoEmpleado,Nombres,Apellidos,DPIHash,Direccion,Municipio,Departamento,Telefono,Correo,Licencia,FechaVencimientoLicencia,Activo,FechaRegistro)
SELECT CONCAT('DEMO-PIL-',b.BusID),N'Piloto de prueba',CONCAT(N'Unidad ',b.BusID),HASHBYTES('SHA2_256',CONCAT('PILOTO-',b.BusID)),N'Dirección ficticia para pruebas',N'Guatemala',N'Guatemala','55550003',CONCAT('piloto',b.BusID,'@demo.example'),CONCAT('LIC-DEMO-',b.BusID),'2030-12-31',1,@Ahora
FROM ops.Bus b WHERE b.CodigoInterno LIKE 'DEMO-%' AND NOT EXISTS(SELECT 1 FROM ops.Piloto p WHERE p.CodigoEmpleado=CONCAT('DEMO-PIL-',b.BusID));
INSERT ops.HistorialEducativoPiloto(PilotoID,Nivel,Institucion,Titulo,AnioFinalizacion,Observacion)
SELECT p.PilotoID,'DIVERSIFICADO',N'Instituto ficticio',N'Bachillerato de demostración',2020,N'Registro educativo ficticio.'
FROM ops.Piloto p WHERE p.CodigoEmpleado LIKE 'DEMO-PIL-%' AND NOT EXISTS(SELECT 1 FROM ops.HistorialEducativoPiloto h WHERE h.PilotoID=p.PilotoID);
INSERT ops.AsignacionPilotoBus(BusID,PilotoID,FechaInicio,FechaFin)
SELECT b.BusID,p.PilotoID,DATEADD(day,-3,@Ahora),NULL FROM ops.Bus b JOIN ops.Piloto p ON p.CodigoEmpleado=CONCAT('DEMO-PIL-',b.BusID)
WHERE b.Estado<>'MANTENIMIENTO' AND NOT EXISTS(SELECT 1 FROM ops.AsignacionPilotoBus a WHERE (a.BusID=b.BusID OR a.PilotoID=p.PilotoID) AND a.FechaFin IS NULL);
-- Usuarios: hash PBKDF2 SHA-512, 120000 iteraciones, 64 bytes; nunca texto plano en la tabla.
INSERT seg.Usuario(OperadorID,NombreUsuario,Correo,ContrasenaHash,ContrasenaSalt,Activo,IntentosFallidos,BloqueadoHasta,UltimoAcceso,FechaCreacion)
SELECT CASE WHEN v.Nombre='demo.operador' THEN (SELECT TOP(1) OperadorID FROM ops.Operador WHERE CodigoEmpleado LIKE 'DEMO-O-%' ORDER BY OperadorID) ELSE NULL END,
v.Nombre,v.Correo,0x0d1975977ccedff05f3a31e6f1722c0c977e902eb9b80775335afb6b87a3be8e992f218bc31bebc8a07c08c77bb0cdadfc78525d9efa74fd2d3f8ab1e91c509b,0x3622a1e8a87ee59f701fe14bf68483b004e51c2d91cd87e7032cc737e46ae6cc,1,0,NULL,NULL,@Ahora
FROM(VALUES('demo.admin','demo.admin@demo.example'),('demo.operador','demo.operador@demo.example'),('demo.auditor','demo.auditor@demo.example'))v(Nombre,Correo)
WHERE NOT EXISTS(SELECT 1 FROM seg.Usuario u WHERE u.NombreUsuario=v.Nombre);
INSERT seg.UsuarioRol(UsuarioID,RolID,FechaAsignacion)
SELECT u.UsuarioID,r.RolID,@Ahora FROM seg.Usuario u JOIN seg.Rol r ON r.Nombre=CASE u.NombreUsuario WHEN 'demo.admin' THEN N'Administrador' WHEN 'demo.operador' THEN N'Operador de estacion' ELSE N'Auditor' END
WHERE u.NombreUsuario IN('demo.admin','demo.operador','demo.auditor') AND NOT EXISTS(SELECT 1 FROM seg.UsuarioRol ur WHERE ur.UsuarioID=u.UsuarioID AND ur.RolID=r.RolID);
DECLARE @UsuarioDemo INT=(SELECT UsuarioID FROM seg.Usuario WHERE NombreUsuario='demo.admin');
EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID',@value=@UsuarioDemo;
-- Titulares con DPI 8 y 9 dígitos, y tarjetas sin vencimiento.
INSERT fin.TitularTarjeta(Nombres,Apellidos,Correo,Telefono,DocumentoHash,FechaRegistro,DPI)
SELECT v.Nombres,v.Apellidos,CONCAT('titular',v.DPI,'@demo.example'),'55550004',HASHBYTES('SHA2_256',v.DPI),@Ahora,v.DPI
FROM(VALUES('88000001',N'Ana',N'García'),('88000002',N'Carlos',N'López'),('88000003',N'María',N'Pérez'),('88000004',N'José',N'Ramírez'),('88000005',N'Lucía',N'Gómez'),('990000001',N'Pedro',N'Morales'),('990000002',N'Sofía',N'Díaz'),('990000003',N'Diego',N'Castillo'),('990000004',N'Elena',N'Juárez'),('990000005',N'Miguel',N'Vásquez'))v(DPI,Nombres,Apellidos)
WHERE NOT EXISTS(SELECT 1 FROM fin.TitularTarjeta t WHERE t.DPI=v.DPI);
INSERT fin.TarjetaAcceso(TitularID,NumeroToken,Saldo,Estado,FechaEmision,FechaVencimiento)
SELECT t.TitularID,CONCAT('DEMO-TAR-',t.DPI),0,'ACTIVA',CAST(@Ahora AS DATE),NULL FROM fin.TitularTarjeta t
WHERE t.DPI IN('88000001','88000002','88000003','88000004','88000005','990000001','990000002','990000003','990000004','990000005')
AND NOT EXISTS(SELECT 1 FROM fin.TarjetaAcceso a WHERE a.NumeroToken=CONCAT('DEMO-TAR-',t.DPI));
DECLARE @Tarjeta BIGINT,@Ref VARCHAR(80),@Tx BIGINT,@Estacion INT,@Linea INT;
SELECT TOP(1) @Linea=LineaID,@Estacion=EstacionID FROM ops.LineaEstacion ORDER BY LineaID,Orden;
DECLARE tarjetas CURSOR LOCAL FAST_FORWARD FOR SELECT TarjetaID FROM fin.TarjetaAcceso WHERE NumeroToken LIKE 'DEMO-TAR-%';
OPEN tarjetas;FETCH NEXT FROM tarjetas INTO @Tarjeta;
WHILE @@FETCH_STATUS=0
BEGIN
 SET @Ref=CONCAT('DEMO-REC-',@Tarjeta);
 IF NOT EXISTS(SELECT 1 FROM fin.TransaccionTarjeta WHERE Referencia=@Ref)
    EXEC fin.sp_RegistrarMovimientoTarjeta @TarjetaID=@Tarjeta,@Tipo='R',@Monto=50.00,@Referencia=@Ref;
 SET @Ref=CONCAT('DEMO-PAG-',@Tarjeta);
 IF NOT EXISTS(SELECT 1 FROM fin.TransaccionTarjeta WHERE Referencia=@Ref)
    EXEC fin.sp_RegistrarMovimientoTarjeta @TarjetaID=@Tarjeta,@Tipo='P',@Monto=2.00,@Referencia=@Ref,@EstacionID=@Estacion;
 SELECT @Tx=TransaccionID FROM fin.TransaccionTarjeta WHERE Referencia=@Ref;
 IF NOT EXISTS(SELECT 1 FROM fin.PaseLineaTarjeta WHERE TransaccionID=@Tx)
    INSERT fin.PaseLineaTarjeta(TarjetaID,LineaID,EstacionID,TransaccionID,FechaInicio,FechaFin)
    VALUES(@Tarjeta,@Linea,@Estacion,@Tx,DATEADD(minute,-1,@Ahora),@Ahora);
 FETCH NEXT FROM tarjetas INTO @Tarjeta;
END;
CLOSE tarjetas;DEALLOCATE tarjetas;
-- Historial de cambio de parqueo de una reserva: lo escribe el trigger.
DECLARE @Reserva INT=(SELECT BusID FROM ops.Bus WHERE CodigoInterno='DEMO-RESERVA'),@ParqueoNuevo INT;
SELECT TOP(1) @ParqueoNuevo=ParqueoID FROM ops.Parqueo WHERE Codigo LIKE 'DEMO-P-%' AND ParqueoID<>(SELECT ParqueoID FROM ops.Bus WHERE BusID=@Reserva) ORDER BY ParqueoID;
IF @ParqueoNuevo IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ops.HistorialParqueoBus WHERE BusID=@Reserva AND Motivo=N'Cambio ficticio de prueba')
    EXEC ops.sp_ReasignarParqueoBus @BusID=@Reserva,@ParqueoNuevoID=@ParqueoNuevo,@Motivo=N'Cambio ficticio de prueba';
-- Recorrido en curso por línea demo, primera llegada y conteos de baja ocupación/alta espera.
DECLARE @Bus INT,@Piloto INT,@Viaje BIGINT,@Primera INT,@CapEst SMALLINT;
DECLARE rutas CURSOR LOCAL FAST_FORWARD FOR
SELECT lb.LineaID,MIN(b.BusID) FROM ops.LineaBus lb JOIN ops.Bus b ON b.BusID=lb.BusID
WHERE b.CodigoInterno LIKE 'DEMO-L%' GROUP BY lb.LineaID;
OPEN rutas;FETCH NEXT FROM rutas INTO @Linea,@Bus;
WHILE @@FETCH_STATUS=0
BEGIN
 SELECT @Piloto=PilotoID FROM ops.AsignacionPilotoBus WHERE BusID=@Bus AND FechaFin IS NULL;
 IF @Piloto IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ops.Viaje WHERE BusID=@Bus)
 BEGIN
  INSERT ops.Viaje(LineaID,BusID,PilotoID,FechaSalida,FechaLlegada,Estado)VALUES(@Linea,@Bus,@Piloto,DATEADD(minute,-10,@Ahora),NULL,'EN_CURSO');
  SET @Viaje=SCOPE_IDENTITY();
  INSERT ops.VisitaEstacionViaje(ViajeID,EstacionID,OrdenVisita,LlegadaProgramada,LlegadaReal,SalidaReal)
  SELECT @Viaje,le.EstacionID,le.Orden,DATEADD(minute,(le.Orden-1)*3,@Ahora),CASE WHEN le.Orden=1 THEN DATEADD(minute,-7,@Ahora) END,NULL FROM ops.LineaEstacion le WHERE le.LineaID=@Linea;
  SELECT TOP(1) @Primera=EstacionID FROM ops.LineaEstacion WHERE LineaID=@Linea ORDER BY Orden;
  SELECT @CapEst=CapacidadReferencia FROM ops.Estacion WHERE EstacionID=@Primera;
  INSERT ops.RegistroParadaViaje(ViajeID,EstacionID,PasajerosAntes,Suben,Bajan,PasajerosDespues,EsperanEstacion,FechaRegistro)
  VALUES(@Viaje,@Primera,0,8,0,8,@CapEst*2,DATEADD(minute,-7,@Ahora));
  EXEC ops.sp_RegistrarConteoEstacion @EstacionID=@Primera,@CantidadPasajeros=0;
  DECLARE @Esperan INT=@CapEst*2;
  EXEC ops.sp_RegistrarConteoEstacion @EstacionID=@Primera,@CantidadPasajeros=@Esperan;
  EXEC ops.sp_RegistrarOcupacionBus @BusID=@Bus,@EstacionID=@Primera,@CantidadPasajeros=8,@ViajeID=@Viaje;
  UPDATE ops.Bus SET Estado='EN_RUTA' WHERE BusID=@Bus;
 END;
 FETCH NEXT FROM rutas INTO @Linea,@Bus;
END;
CLOSE rutas;DEALLOCATE rutas;
-- Un recorrido finalizado: segundo bus demo de la primera línea que disponga de él.
DECLARE @HistoricoBus INT,@HistoricoLinea INT,@HistoricoPiloto INT,@HistoricoViaje BIGINT;
SELECT TOP(1) @HistoricoBus=b.BusID,@HistoricoLinea=lb.LineaID,@HistoricoPiloto=a.PilotoID
FROM ops.Bus b JOIN ops.LineaBus lb ON lb.BusID=b.BusID JOIN ops.AsignacionPilotoBus a ON a.BusID=b.BusID AND a.FechaFin IS NULL
WHERE b.CodigoInterno LIKE 'DEMO-L%' AND (SELECT COUNT(*) FROM ops.LineaEstacion WHERE LineaID=lb.LineaID)>=2 AND NOT EXISTS(SELECT 1 FROM ops.Viaje v WHERE v.BusID=b.BusID) ORDER BY lb.LineaID,b.BusID;
IF @HistoricoBus IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ops.Viaje WHERE Estado='FINALIZADO' AND BusID IN(SELECT BusID FROM ops.Bus WHERE CodigoInterno LIKE 'DEMO-L%'))
BEGIN
 DECLARE @InicioHist DATETIME2(0)=DATEADD(day,-1,@Ahora),@CantidadEst INT=(SELECT COUNT(*) FROM ops.LineaEstacion WHERE LineaID=@HistoricoLinea);
 INSERT ops.Viaje(LineaID,BusID,PilotoID,FechaSalida,FechaLlegada,Estado)
 VALUES(@HistoricoLinea,@HistoricoBus,@HistoricoPiloto,@InicioHist,DATEADD(minute,@CantidadEst*10,@InicioHist),'FINALIZADO');
 SET @HistoricoViaje=SCOPE_IDENTITY();
 INSERT ops.VisitaEstacionViaje(ViajeID,EstacionID,OrdenVisita,LlegadaProgramada,LlegadaReal,SalidaReal)
 SELECT @HistoricoViaje,EstacionID,Orden,DATEADD(minute,(Orden-1)*10,@InicioHist),DATEADD(minute,(Orden-1)*10,@InicioHist),DATEADD(minute,(Orden-1)*10+2,@InicioHist)
 FROM ops.LineaEstacion WHERE LineaID=@HistoricoLinea;
 INSERT ops.RegistroParadaViaje(ViajeID,EstacionID,PasajerosAntes,Suben,Bajan,PasajerosDespues,EsperanEstacion,FechaRegistro)
 SELECT @HistoricoViaje,EstacionID,CASE WHEN Orden=1 THEN 0 ELSE 30 END,CASE WHEN Orden=1 THEN 30 ELSE 0 END,
 CASE WHEN Orden=@CantidadEst THEN 30 ELSE 0 END,CASE WHEN Orden=@CantidadEst THEN 0 ELSE 30 END,12,DATEADD(minute,(Orden-1)*10+1,@InicioHist)
 FROM ops.LineaEstacion WHERE LineaID=@HistoricoLinea;
END;
EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID',@value=NULL;
COMMIT;
PRINT N'Datos ficticios cargados. Tarjetas DEMO-TAR-88000001 hasta DEMO-TAR-990000005 con saldo inicial Q48.';
END TRY
BEGIN CATCH
 EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID',@value=NULL;
 IF CURSOR_STATUS('local','tarjetas')>=0 CLOSE tarjetas;
 IF CURSOR_STATUS('local','tarjetas')>=-1 DEALLOCATE tarjetas;
 IF CURSOR_STATUS('local','rutas')>=0 CLOSE rutas;
 IF CURSOR_STATUS('local','rutas')>=-1 DEALLOCATE rutas;
 IF @@TRANCOUNT>0 ROLLBACK;
 THROW;
END CATCH;
GO
-- Datos de prueba por módulo y consulta de integridad.
SELECT NombreUsuario,Correo,OperadorID FROM seg.Usuario WHERE NombreUsuario LIKE 'demo.%';
SELECT NumeroToken,Saldo,Estado FROM fin.TarjetaAcceso WHERE NumeroToken LIKE 'DEMO-TAR-%';
SELECT LineaID,COUNT(*) BusesAsignados FROM ops.LineaBus GROUP BY LineaID;
SELECT * FROM ops.Viaje WHERE BusID IN(SELECT BusID FROM ops.Bus WHERE CodigoInterno LIKE 'DEMO-L%');
EXEC ops.sp_ValidarIntegridadOperativa;
GO
