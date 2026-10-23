-- Datos de referencia oficiales: Municipalidad de Guatemala, datasets Transmetro 2025.
-- Revisar en una copia/backup antes de ejecutar. Script SQL Server para esquemas cat y ops.
-- Coordenadas CSV x/y transformadas desde Web Mercator (EPSG:3857) a latitud/longitud decimal.
-- IMPORTANTE: el CSV no trae secuencia oficial de paradas por sentido; Orden se asigna por FID
-- de origen como orden provisional, NO debe considerarse itinerario validado.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @MunicipalidadID int;
    SELECT @MunicipalidadID = MunicipalidadID FROM cat.Municipalidad WHERE Codigo = 'MUNI-GUA';
    IF @MunicipalidadID IS NULL
    BEGIN
        INSERT INTO cat.Municipalidad (Codigo, Nombre, Departamento, Telefono, Correo, Direccion, Activa, FechaCreacion)
        VALUES ('MUNI-GUA', N'Municipalidad de Guatemala', N'Guatemala', NULL, NULL, N'Ciudad de Guatemala, Guatemala', 1, SYSUTCDATETIME());
        SELECT @MunicipalidadID = MunicipalidadID FROM cat.Municipalidad WHERE Codigo = 'MUNI-GUA';
    END;

    -- Líneas y variantes de servicio del dataset RUTAS_SISTEMA_TRANSMETRO_2025.
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'1000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'1000', N'Línea 1', N'Ruta oficial 2025; longitud publicada: 4757.96 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'2000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'2000', N'Línea 2', N'Ruta oficial 2025; longitud publicada: 3616.69 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'6000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'6000', N'Línea 6', N'Ruta oficial 2025; longitud publicada: 13251.51 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'12000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'12000', N'Línea 12', N'Ruta oficial 2025; longitud publicada: 24626.97 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'13000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'13000', N'Línea 13', N'Ruta oficial 2025; longitud publicada: 12801.34 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'13001')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'13001', N'Línea 13 Extención', N'Ruta oficial 2025; longitud publicada: 4644.34 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'18000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'18000', N'Línea 18', N'Ruta oficial 2025; longitud publicada: 12928.69 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'7000')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'7000', N'Línea 7', N'Ruta oficial 2025; longitud publicada: 25097.46 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'18002')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'18002', N'Línea 18 Expres (Directo Plaza Barrios)', N'Ruta oficial 2025; longitud publicada: 21838.81 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'12001')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'12001', N'Línea 12 (Directo Amate)', N'Ruta oficial 2025; longitud publicada: 24626.97 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'12002')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'12002', N'Línea 12 (Directo Trébol)', N'Ruta oficial 2025; longitud publicada: 24626.97 m.', 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Linea WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'18001')
        INSERT INTO ops.Linea (MunicipalidadID, Codigo, Nombre, Descripcion, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'18001', N'Línea 18 Expres (Directo San Rafael)', N'Ruta oficial 2025; longitud publicada: 21838.81 m.', 'P', SYSUTCDATETIME());

    -- Estaciones deduplicadas por nombre, dirección, zona y ubicación.
    -- Codigo TM-### es un identificador interno generado para esta carga.
    -- El estado 'P' respeta el valor por defecto definido en el modelo C#.
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-001')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-001', N'Estación San Sebastián', N'3 calle 6  avenida zona 1', 14.6458262, -90.5129905, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-002')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-002', N'Estación Jocotenango', N'6ª avenida y 4ª calle zona 2', 14.6510092, -90.5131207, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-003')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-003', N'Estación Simeón Cañas', N'avenida simeón cañas y 6ª calle zona 2', 14.6539483, -90.5118797, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-004')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-004', N'Estación Hipódromo del Norte', N'avenida simeón cañas y 11 calle zona 2', 14.6592151, -90.5099874, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-005')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-005', N'San José de la Montaña', N'6 avenida y 6 calle zona 2', 14.6538430, -90.5119446, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-006')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-006', N'Estación Plaza Barrios - Fegua', N'18 calle y 10ª avenida zona 1', 14.6305211, -90.5117312, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-007')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-007', N'Estación Beatas de Belén', N'8 avenida 14 calle zona 1', 14.6339209, -90.5126772, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-008')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-008', N'Estación Capuchinas', N'10ª avenida y 10 calle zona 1', 14.6386537, -90.5098995, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-009')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-009', N'Estación Cerro del Carmen', N'1ª calle y 13 avenida zona 6, zona 2', 14.6481809, -90.5048774, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-010')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-010', N'Estación José Martí', N'14 avenida y 7ª calle zona 6', 14.6529507, -90.4999823, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-011')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-011', N'Estación Corpus Christi', N'15 avenida y 10 calle zona 6', 14.6561028, -90.4971981, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-012')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-012', N'Estación Quintanal', N'15 avenida y 13 calle zona 6', 14.6584871, -90.4960165, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-013')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-013', N'Estación Academia', N'16 avenida y 15 calle zona 6', 14.6590484, -90.4940477, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-014')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-014', N'Estación Centro Zona 6', N'16 avenida y 10 calle zona 6', 14.6549407, -90.4960099, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-015')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-015', N'Estación IGSS Zona 6', N'16 avenida y 6ª calle zona 6', 14.6515545, -90.4974427, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-016')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-016', N'Estación Parroquia', N'15 avenida y 3ª calle zona 6', 14.6500780, -90.4997540, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-017')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-017', N'Estación Cerro del Carmen', N'1 calle y 13 avenida zona 1', 14.6480685, -90.5046830, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-018')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-018', N'Colón - Líneas 6 y 18', N'11 avenida y 8ª calle zona 1', 14.6400530, -90.5083064, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-019')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-019', N'Francos Monroy  - Líneas 6 y 18', N'11 avenida y 15 calle zona 1', 14.6326463, -90.5093307, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-020')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-020', N'Estación San Martín', N'20 avenida y 1ª calle zona 1', 14.6448897, -90.4965206, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-021')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-021', N'Estación Victorias', N'avenida las victorias y 3ª calle zona 6', 14.6481675, -90.4937659, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-022')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-022', N'Estación Atlántida', N'11 avenida (boulevard álvaro arzú) zona 18', 14.6497965, -90.4782309, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-023')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-023', N'Estación Victorias', N'avenida las victorias y 3ª calle zona 6', 14.6480767, -90.4936187, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-024')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-024', N'Estación San Martín', N'1ª calle y 9ª avenida zona 1', 14.6452673, -90.4967085, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-025')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-025', N'Estación Juan Pablo II', N'avenida las américa y 21 calle zona 14', 14.5741304, -90.5242099, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-026')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-026', N'Estación Plaza Berlín', N'frente a plaza berlín zona 13', 14.5699219, -90.5266742, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-027')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-027', N'Estación Correos', N'8 avenida 11 calle zona 1', 14.6371623, -90.5122483, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-028')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-028', N'Estación Mercado Central', N'8ª avenida y 6ª calle zona 1', 14.6423369, -90.5114997, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-029')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-029', N'Estación Parque Centenario', N'5 avenida 7 calle zona 1', 14.6420647, -90.5148041, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-030')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-030', N'Estación San Agustín', N'5 avenida  10 a calle zona 1', 14.6384944, -90.5152606, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-031')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-031', N'Estación Gómez Carrillo', N'5 avenida 14 calle zona 1', 14.6345859, -90.5157816, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-032')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-032', N'Estación Cipresales', N'avenida la pedrera y 18 calle zona 6', 14.6653036, -90.4938193, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-033')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-033', N'Estación Proyectos 4-4', N'avenida la pedrera y 20 calle zona 6', 14.6675525, -90.4920014, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-034')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-034', N'Estación Proyectos', N'avenida la pedrera y 25 calle zona 6', 14.6733299, -90.4874615, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-035')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-035', N'Estación Centro Cívico', N'21 calle y 6 avenia A zona 1', 14.6277276, -90.5148198, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-036')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-036', N'Estación Sur 2', N'5 avenida y 18 calle zona 1', 14.6313136, -90.5162887, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-037')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-037', N'Estación Paseo de las Letras', N'8 avenida y 20 calle zona 1', 14.6299427, -90.5133536, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-038')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-038', N'Estación La Merced', N'11 avenida y 4 calle zona 1', 14.6434701, -90.5079219, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-039')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-039', N'Estacion Santa Teresa', N'10 avenia y 4 calle zona 1', 14.6441074, -90.5091358, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-040')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-040', N'Estación Plaza Barrios', N'9 avenida y 18 calle zona 1', 14.6301463, -90.5122245, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-041')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-041', N'Estación Plaza Municipal', N'6 avenida y 21 calle zona 1', 14.6275977, -90.5157923, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-042')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-042', N'Estación El Calvario', N'6 avenida y 20 calle zona 1', 14.6298716, -90.5156242, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-043')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-043', N'Estación Don Bosco', N'1 avenida y 25 calle zona 1', 14.6251145, -90.5221628, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-044')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-044', N'Estación Bolívar Direccion Plaza Barrios', N'avenida bolivar y 32 calle zona 8, zona 3', 14.6191470, -90.5276902, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-045')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-045', N'Estación Santa Cecília', N'avenida bolivar y 39 calle. zona 8, zona 3', 14.6145780, -90.5330715, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-046')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-046', N'Estación Trébol', N'el trebol zona 12', 14.6126366, -90.5357042, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-047')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-047', N'Estación Mariscal Direccion Plaza Barrios', N'calz. aguilar batres y 13 calle zona 12, zona 11', 14.6047081, -90.5450855, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-048')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-048', N'Estación Reformita Dirección Plaza Barrios', N'calz. aguilar batres y 19 calle zona 12, zona 11', 14.6010406, -90.5495809, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-049')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-049', N'Estación El Carmen', N'calz. aguilar batres y 30 calle zona 12, zona 11', 14.5961045, -90.5557533, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-050')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-050', N'Estación Las Charcas Dirección Plaza Barrios', N'calz. aguilar batres y 33 calle zona 12, zona 11', 14.5926604, -90.5588687, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-051')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-051', N'Estación Centra Sur', N'22 calle final, villa nueva, zona 12', 14.5645561, -90.5637007, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-052')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-052', N'Estación Monte María', N'calz. aguilar batres y 45 calle, zona 12 ,villa nueva', 14.5810846, -90.5676198, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-053')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-053', N'Estación Javier', N'calz. aguilar batres y 38 calle, zona 12, villa nueva', 14.5871674, -90.5626534, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-054')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-054', N'Estación Las Charcas Dirección Central Sur', N'calz. aguilar batres y 34 calle zona 12, zona 11', 14.5938512, -90.5581758, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-055')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-055', N'Estación Reformita Dirección Central Sur', N'calzada aguilar batres y 21 calle zona 12, zona 11', 14.6022266, -90.5481677, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-056')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-056', N'Estación Mariscal Dirección Central Sur', N'calz. aguilar batres y 15 calle zona 12, zona 11', 14.6055643, -90.5442387, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-057')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-057', N'Estación Bolívar Dirección Central Sur', N'avenida bolivar y 31 calle zona 8, zona 3', 14.6199059, -90.5270673, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-058')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-058', N'Estación Plaza El Amate', N'4 avenida y 18 calle zona 1', 14.6313339, -90.5168112, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-059')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-059', N'Estación Banco de Guatemala', N'7 avenida y 22 calle zona 1', 14.6261247, -90.5146290, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-060')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-060', N'Estación Plaza de la República', N'7 avenida, intersección ruta 4 y via 5 zona 4', 14.6199173, -90.5154691, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-061')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-061', N'Estación Torre del Reformador', N'7 avenida y 1 calle zona 9', 14.6139798, -90.5164622, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-062')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-062', N'Estación Seis 26', N'7 avenida y 5 calle zona 9', 14.6092388, -90.5173243, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-063')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-063', N'Estación IGSS Zona 9', N'7 avenida y 10 calle zona 9', 14.6042123, -90.5182778, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-064')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-064', N'Estación Plaza España', N'7 avenida y 13 calle zona 9', 14.5996261, -90.5191609, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-065')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-065', N'Estación Los Arcos', N'15 avenida y 4 calle zona 13', 14.5921319, -90.5208025, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-066')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-066', N'Estación Plaza Argentina', N'15 avenida y 11 calle zona 13', 14.5858816, -90.5225092, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-067')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-067', N'Estación Hangares', N'15 avenida y 18 calle zona 13', 14.5802267, -90.5242875, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-068')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-068', N'Estación Fuerza Aérea', N'av. hincapie y 11 calle zona 13', 14.5876083, -90.5233629, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-069')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-069', N'Estación Acueducto', N'av. hincapie y 4 calle zona 13', 14.5933570, -90.5217611, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-070')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-070', N'Estación Montufar', N'6 avenida y 13 calle zona 9', 14.6006144, -90.5207657, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-071')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-071', N'Estación Tívoli', N'6 avenida y 10 calle zona 9', 14.6044838, -90.5200084, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-072')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-072', N'Estación Industria', N'6 avenida y 6 calle zona 9', 14.6095760, -90.5190246, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-073')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-073', N'Estación Terminal', N'6 avenida y 2 calle zona 9', 14.6137127, -90.5182264, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-074')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-074', N'Estación Exposición', N'6 avenida y ruta 6 zona 4', 14.6194270, -90.5170919, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-075')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-075', N'Estación 4 Grados Sur', N'6 avenida y 24 calle zona 4', 14.6242695, -90.5164138, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-076')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-076', N'Estación Tipografía', N'18 calle zona 1', 14.6308696, -90.5144169, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-077')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-077', N'Estación San Juan Sur', N'Anillo Periferico Sur y 4 calle zona 7', 14.6305965, -90.5548608, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-078')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-078', N'Estación Roosevelt Sur', N'Anillo Periferico Sur y 30 avenida zona 7, zona 11', 14.6259945, -90.5591342, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-079')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-079', N'Estación Usac / Periferico', N'Anillo Periferico y 29 calle zona 12', 14.5930977, -90.5506155, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-080')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-080', N'Estación Roosevelt Norte', N'Anillo Periferico Norte y 30 avenida zona 11', 14.6260779, -90.5586011, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-081')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-081', N'Estación San Juan Norte', N'Anillo Periferico Norte y 5 calle zona 7', 14.6303680, -90.5546761, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-082')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-082', N'Estación La Merced', N'11 avenida y 5 calle zona 1', 14.6434701, -90.5079219, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-083')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-083', N'Estación San Rafael', N'Boulevard San Rafael y 3 aveniada B zona 18', 14.6549820, -90.4520612, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-084')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-084', N'Estación Paraíso I', N'Boulevard San Rafael y 20 avenida zona 18', 14.6590402, -90.4466948, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-085')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-085', N'Estación La Merced', N'11 avenida y 4 calle zona 1', 14.6434701, -90.5079219, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-086')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-086', N'Estación Bolívar', N'avenida bolivar y 32 calle zona 8, zona 3', 14.6191470, -90.5276902, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-087')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-087', N'Estación Mariscal', N'calz. aguilar batres y 13 calle zona 12, zona 11', 14.6047081, -90.5450855, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-088')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-088', N'Estación Reformita', N'calz. aguilar batres y 19 calle zona 12, zona 11', 14.6010406, -90.5495809, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-089')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-089', N'Estación Las Charcas', N'calz. aguilar batres y 33 calle zona 12, zona 11', 14.5926604, -90.5588687, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-090')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-090', N'Estación Las Charcas', N'calz. aguilar batres y 34 calle zona 12, zona 11', 14.5938512, -90.5581758, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-091')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-091', N'Estación Reformita', N'calzada aguilar batres y 21 calle zona 12, zona 11', 14.6022266, -90.5481677, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-092')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-092', N'Estación Mariscal', N'calz. aguilar batres y 15 calle zona 12, zona 11', 14.6055643, -90.5442387, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-093')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-093', N'Estación Bolívar', N'avenida bolivar y 31 calle zona 8, zona 3', 14.6199059, -90.5270673, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-094')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-094', N'Estación San Rafael', N'Boulvard San Rafael y 3 avenida b, zona 18', 14.6549820, -90.4520612, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-095')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-095', N'Estación Paraíso I', N'Boulevard San Rafael y 20 avenida, zona 18', 14.6590402, -90.4466948, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-096')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-096', N'Granai - Dir. La Merced', N'Anillo Periferico Norte  zona 11', 14.5996353, -90.5591351, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-097')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-097', N'Granai - Dir. La Merced', N'Anillo Periferico Sur zona 11', 14.5995718, -90.5595287, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-098')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-098', N'Rodolfo Robles - Dir. USAC Periférico', N'Anillo Periferico Sur y 18 avenida zona 11', 14.6076750, -90.5580930, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-099')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-099', N'Rodolfo Robles - Dir. La Merced', N'Anillo Periferico y 20 calle zona 11', 14.6070710, -90.5582115, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-100')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-100', N'CEJUSA - Dir. La Merced', N'Anillo Periferico Norte y 18 calle zona 11', 14.6094381, -90.5565236, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-101')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-101', N'CEJUSA - Dir. USAC Periférico', N'Anillo Periferico Sur y 18 calle zona 11', 14.6100939, -90.5564318, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-102')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-102', N'San Jorge - Dir. La Merced', N'Anillo Periferico Norte y 21 avenida zona 11', 14.6183576, -90.5556843, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-103')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-103', N'San Jorge - Dir. USAC Periférico', N'Anillo Periferico Sur y 9 calle zona 11', 14.6192966, -90.5565554, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-104')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-104', N'Ciudad de Plata II - Dir. La Merced', N'Anillo Periferico Norte y 14 calle zona 7', 14.6383077, -90.5505571, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-105')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-105', N'Ciudad de Plata II - Dir. USAC Periférico', N'Anillo Periferico Sur y 13 calle zona 7', 14.6384912, -90.5507536, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-106')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-106', N'Villa Linda - Dir. La Merced', N'Anillo Periferico Norte y 31 avenida zona 7', 14.6413315, -90.5462541, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-107')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-107', N'Villa Linda - Dir. USAC Periférico', N'Anillo Periferico Sur y 19 calle zona 7', 14.6422292, -90.5455036, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-108')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-108', N'4 de febrero - Dir. La Merced', N'Anillo Periferico Norte y 23 calle zona 7', 14.6449154, -90.5396829, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-109')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-109', N'4 de febrero - Dir. USAC Periférico', N'Anillo Periferico Sur y 22 calle A zona 7', 14.6445086, -90.5408257, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-110')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-110', N'Bethania - Dir. USAC Periférico', N'Anillo Periferico Sur y 33 avenida zona 7', 14.6458883, -90.5368110, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-111')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-111', N'Bethania - Dir. La Merced', N'Anillo Periferico Norte 25 calle zona 7', 14.6455499, -90.5365945, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-112')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-112', N'Incienso - Dir. La Merced', N'Anillo Periferico Norte  zona 7', 14.6487106, -90.5309663, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-113')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-113', N'Incienso - Dir. USAC Periférico', N'Anillo Periferico Sur y 31 avenida A zona 7', 14.6487931, -90.5313983, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-114')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-114', N'San Juan de Dios', N'9 calle y 1 avenida zona 1', 14.6412301, -90.5188897, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-115')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-115', N'Pasaje Aycinena', N'9 calle y 6 avenida zona 1', 14.6403189, -90.5130679, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-116')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-116', N'Cruz Roja', N'4 calle y 8 avenida zona 1', 14.6442418, -90.5109467, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-117')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-117', N'Santuario de Guadalupe', N'8 calle y 1 avenida zona 1', 14.6420880, -90.5193033, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-118')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-118', N'Cantón Exposición', N'7 avenida ruta 2 zona 4', 14.6223700, -90.5151461, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-119')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-119', N'Atlántida', N'11 avenida  y 3 calle zona 18', 14.6510328, -90.4779895, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-120')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-120', N'Portales', N'CA-9 NORTE Ruta al Atlantico, zona 17', 14.6487329, -90.4819852, 80, 'P', SYSUTCDATETIME());
    IF NOT EXISTS (SELECT 1 FROM ops.Estacion WHERE MunicipalidadID = @MunicipalidadID AND Codigo = N'TM-121')
        INSERT INTO ops.Estacion (MunicipalidadID, Codigo, Nombre, Direccion, Latitud, Longitud, CapacidadReferencia, Estado, FechaCreacion)
        VALUES (@MunicipalidadID, N'TM-121', N'Archivo General', N'4 avenia y 7 calle zona 1', 14.6424275, -90.5156983, 80, 'P', SYSUTCDATETIME());

    -- Relación línea-estación. El orden es provisional (FID fuente); validar el recorrido antes de usarlo en pantalla.
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-001')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-001';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-027')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-027';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-028')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-028';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-029')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-029';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-030')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-030';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-031')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-031';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-035')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-035';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-036')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-036';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-037')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-037';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.Codigo = N'TM-007')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'1000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-007';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.Codigo = N'TM-002')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-002';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.Codigo = N'TM-003')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-003';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.Codigo = N'TM-004')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-004';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.Codigo = N'TM-005')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-005';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.Codigo = N'TM-001')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'2000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-001';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-006')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-006';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-007')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-007';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-008')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-008';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-009')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-009';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-010')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-010';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-011')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-011';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-012')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-012';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-013')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-013';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-014')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-014';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-015')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-015';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-016')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-016';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-017')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-017';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-018')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-018';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-019')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-019';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-032')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-032';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-033')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-033';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-034')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-034';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-038')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-038';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.Codigo = N'TM-039')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'6000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-039';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-020')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-020';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-021')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-021';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-022')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-022';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-023')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-023';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-024')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-024';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-018')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-018';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-006')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-006';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-007')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-007';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-008')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-008';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-017')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-017';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-019')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-019';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-085')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-085';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-119')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-119';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.Codigo = N'TM-120')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-120';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.Codigo = N'TM-025')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-025';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.Codigo = N'TM-026')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-026';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.Codigo = N'TM-066')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-066';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.Codigo = N'TM-067')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-067';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-040')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-040';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-042')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-042';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-059')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-059';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-060')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-060';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-061')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-061';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-062')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-062';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-063')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-063';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-064')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-064';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-065')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-065';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-066')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-066';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-067')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-067';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-068')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-068';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-069')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-069';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-070')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-070';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-071')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-071';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-072')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-072';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-073')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-073';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-074')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-074';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-075')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-075';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-076')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 20, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-076';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.Codigo = N'TM-118')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 21, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'13000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-118';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-041')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-041';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-043')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-043';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-044')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-044';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-045')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-045';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-046')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-046';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-047')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-047';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-048')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-048';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-049')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-049';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-050')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-050';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-051')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-051';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-052')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-052';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-053')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-053';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-054')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-054';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-055')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-055';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-056')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-056';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-057')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-057';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-058')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-058';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-040')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-040';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-042')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-042';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.Codigo = N'TM-076')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 20, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-076';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-077')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-077';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-078')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-078';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-079')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-079';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-080')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-080';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-081')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-081';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-082')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-082';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-018')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-018';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-096')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-096';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-097')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-097';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-098')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-098';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-099')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-099';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-100')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-100';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-101')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-101';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-102')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-102';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-103')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-103';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-104')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-104';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-105')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-105';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-106')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-106';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-107')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-107';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-108')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 20, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-108';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-109')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 21, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-109';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-110')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 22, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-110';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-111')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 23, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-111';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-112')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 24, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-112';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-113')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 25, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-113';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-114')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 26, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-114';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-115')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 27, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-115';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-116')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 28, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-116';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-117')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 29, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-117';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.Codigo = N'TM-121')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 30, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'7000' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-121';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.Codigo = N'TM-083')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-083';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.Codigo = N'TM-084')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-084';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.Codigo = N'TM-006')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-006';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-041')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-041';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-043')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-043';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-086')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-086';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-045')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-045';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-046')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-046';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-087')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-087';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-088')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-088';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-049')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-049';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-089')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-089';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-051')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-051';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-052')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-052';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-053')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-053';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-090')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-090';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-091')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-091';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-092')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-092';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-093')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-093';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-058')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-058';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-040')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-040';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-042')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-042';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.Codigo = N'TM-076')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 20, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12001' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-076';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-041')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-041';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-043')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-043';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-086')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-086';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-045')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 4, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-045';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-046')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 5, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-046';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-087')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 6, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-087';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-088')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 7, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-088';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-049')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 8, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-049';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-089')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 9, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-089';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-051')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 10, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-051';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-052')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 11, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-052';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-053')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 12, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-053';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-090')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 13, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-090';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-091')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 14, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-091';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-092')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 15, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-092';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-093')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 16, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-093';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-058')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 17, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-058';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-040')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 18, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-040';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-042')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 19, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-042';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.Codigo = N'TM-076')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 20, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'12002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-076';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.Codigo = N'TM-094')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 1, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-094';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.Codigo = N'TM-095')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 2, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-095';
    IF NOT EXISTS (SELECT 1 FROM ops.LineaEstacion le
        INNER JOIN ops.Linea l ON l.LineaID = le.LineaID
        INNER JOIN ops.Estacion e ON e.EstacionID = le.EstacionID
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.Codigo = N'TM-006')
        INSERT INTO ops.LineaEstacion (LineaID, EstacionID, Orden, TiempoMinuto, FechaAlta)
        SELECT l.LineaID, e.EstacionID, 3, NULL, SYSUTCDATETIME()
        FROM ops.Linea l CROSS JOIN ops.Estacion e
        WHERE l.MunicipalidadID = @MunicipalidadID AND l.Codigo = N'18002' AND e.MunicipalidadID = @MunicipalidadID AND e.Codigo = N'TM-006';

    COMMIT TRANSACTION;
    PRINT 'Carga de líneas, estaciones y relaciones completada.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Verificación posterior:
-- SELECT Codigo, Nombre, Estado FROM ops.Linea WHERE MunicipalidadID = (SELECT MunicipalidadID FROM cat.Municipalidad WHERE Codigo='MUNI-GUA') ORDER BY Codigo;
-- SELECT COUNT(*) AS Estaciones FROM ops.Estacion WHERE MunicipalidadID = (SELECT MunicipalidadID FROM cat.Municipalidad WHERE Codigo='MUNI-GUA');
-- SELECT COUNT(*) AS Relaciones FROM ops.LineaEstacion;