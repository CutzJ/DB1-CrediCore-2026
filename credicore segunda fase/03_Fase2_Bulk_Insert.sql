USE CrediCore;
GO

/* =========================================================================
   FASE 2.3: INGESTA MASIVA CON ARCHIVO PLANO Y BULK INSERT
   Resolución de colisión posicional con columna IDENTITY (IdCredito) 
   mediante vista de desacoplamiento de metadatos.
   ========================================================================= */

-- 1. Crear vista que expone las 6 columnas presentes en prestamos.txt
CREATE OR ALTER VIEW Operaciones.vw_CargaCreditos AS
SELECT 
    IdCliente,
    IdVehiculo,
    MontoOtorgado,
    TasaInteresMensual,
    Estado,
    FechaDesembolso
FROM Operaciones.Creditos;
GO

-- 2. Carga masiva apuntando al archivo copiado en el contenedor Docker
BULK INSERT Operaciones.vw_CargaCreditos
FROM '/tmp/prestamos.txt'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1,
    TABLOCK
);
GO

-- 3. Verificación de integridad y volumen
SELECT COUNT(*) AS TotalCreditos FROM Operaciones.Creditos;
SELECT TOP 5 * FROM Operaciones.Creditos;
GO