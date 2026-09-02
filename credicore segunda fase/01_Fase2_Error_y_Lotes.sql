USE CrediCore;
GO

/* =========================================================================
   PARTE 1: DOCUMENTACIÓN DEL SQL ERROR 10738
   El siguiente bloque supera el límite de 1,000 tuplas en una sola cláusula 
   VALUES. Al descomentarlo y ejecutarlo, SQL Server retorna el error:
   "The number of row value expressions in the INSERT statement exceeds 
   the maximum allowable limit of 1000."
   ========================================================================= */

/*
INSERT INTO Garantias.Vehiculos (Marca, Modelo, Anio, Color, NumeroPlaca, NumeroChasis)
SELECT TOP 1500
    'Toyota', 'Corolla', 2020, 'Blanco', 
    CONCAT('P', RIGHT('0000' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(4)), 4), 'ERR'),
    CONCAT('VIN', RIGHT('00000000000000' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(14)), 14))
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
GO
*/

/* =========================================================================
   PARTE 2: SOLUCIÓN MEDIANTE SEGMENTACIÓN EN LOTES (BATCHING CON 'GO')
   Inserción de 1,500 vehículos divididos en 2 lotes atómicos de 750 registros.
   ========================================================================= */

-- LOTE 1 (750 Vehículos)
INSERT INTO Garantias.Vehiculos (Marca, Modelo, Anio, Color, NumeroPlaca, NumeroChasis)
SELECT TOP 750
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 6)
        WHEN 0 THEN 'Toyota'
        WHEN 1 THEN 'Honda'
        WHEN 2 THEN 'Nissan'
        WHEN 3 THEN 'Mazda'
        WHEN 4 THEN 'Hyundai'
        ELSE 'Ford'
    END,
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 4)
        WHEN 0 THEN 'Corolla'
        WHEN 1 THEN 'Civic'
        WHEN 2 THEN 'Sentra'
        ELSE 'Mazda 3'
    END,
    2015 + (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 10),
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 5)
        WHEN 0 THEN 'Blanco'
        WHEN 1 THEN 'Negro'
        WHEN 2 THEN 'Gris'
        WHEN 3 THEN 'Rojo'
        ELSE 'Azul'
    END,
    CONCAT('P', RIGHT('0000' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(4)), 4), 'AAA'),
    CONCAT('VIN', RIGHT('00000000000000' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(14)), 14))
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
GO

-- LOTE 2 (750 Vehículos)
INSERT INTO Garantias.Vehiculos (Marca, Modelo, Anio, Color, NumeroPlaca, NumeroChasis)
SELECT TOP 750
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 6)
        WHEN 0 THEN 'Toyota'
        WHEN 1 THEN 'Chevrolet'
        WHEN 2 THEN 'Kia'
        WHEN 3 THEN 'Mitsubishi'
        WHEN 4 THEN 'Volkswagen'
        ELSE 'Ford'
    END,
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 4)
        WHEN 0 THEN 'RAV4'
        WHEN 1 THEN 'Tracker'
        WHEN 2 THEN 'Sportage'
        ELSE 'Tiguan'
    END,
    2016 + (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 9),
    CASE (ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) % 5)
        WHEN 0 THEN 'Plata'
        WHEN 1 THEN 'Negro'
        WHEN 2 THEN 'Blanco'
        WHEN 3 THEN 'Vino'
        ELSE 'Gris'
    END,
    CONCAT('P', RIGHT('0000' + CAST(750 + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(4)), 4), 'BBB'),
    CONCAT('VIN', RIGHT('00000000000000' + CAST(750 + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(14)), 14))
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
GO

-- Verificación de volumen
SELECT COUNT(*) AS TotalVehiculos FROM Garantias.Vehiculos;
GO