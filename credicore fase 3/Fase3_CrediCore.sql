USE CrediCore;
GO
-- Conectar Créditos con Clientes
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_Creditos_Clientes
FOREIGN KEY (IdCliente) REFERENCES Operaciones.Clientes(IdCliente);
GO

-- Conectar Créditos con Vehículos (Garantías)
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_Creditos_Vehiculos
FOREIGN KEY (IdVehiculo) REFERENCES Garantias.Vehiculos(IdVehiculo);
GO

-- =======================================================
-- Parte A: La Prueba de Destrucción
-- Intento de borrado para comprobar el bloqueo por Foreign Key (Error 547)
-- =======================================================
DELETE FROM Operaciones.Clientes 
WHERE IdCliente = 1;
GO

-- =======================================================
-- Parte B.1: Reporte Maestro (INNER JOIN Triple)
-- =======================================================
SELECT 
    C.Nombres + ' ' + C.Apellidos AS [Nombre del Cliente],
    C.Telefono,
    V.Marca AS [Marca del Vehiculo],
    V.NumeroPlaca AS Placa,
    CR.MontoOtorgado AS [Monto del Credito],
    CR.Estado AS [Estado Actual]
FROM Operaciones.Creditos CR
INNER JOIN Operaciones.Clientes C ON CR.IdCliente = C.IdCliente
INNER JOIN Garantias.Vehiculos V ON CR.IdVehiculo = V.IdVehiculo;
GO

-- =======================================================
-- Parte B.2: Minería de Potenciales Clientes (LEFT JOIN)
-- =======================================================
SELECT 
    C.Nombres + ' ' + C.Apellidos AS [Nombre del Cliente],
    C.Telefono,
    CR.IdCredito AS [Credito Asignado]
FROM Operaciones.Clientes C
LEFT JOIN Operaciones.Creditos CR ON C.IdCliente = CR.IdCliente
WHERE CR.IdCredito IS NULL;
GO


-- =======================================================
-- Parte C.1: El Filtro Dinámico (Subconsulta en el WHERE)
-- =======================================================
SELECT 
    C.Nombres + ' ' + C.Apellidos AS [Nombre del Cliente],
    CR.MontoOtorgado AS [Monto del Credito]
FROM Operaciones.Creditos CR
INNER JOIN Operaciones.Clientes C ON CR.IdCliente = C.IdCliente
WHERE CR.MontoOtorgado > (
    -- La subconsulta calcula el promedio histórico dinámicamente
    SELECT AVG(MontoOtorgado) FROM Operaciones.Creditos
);
GO

-- =======================================================
-- Parte C.2: Patrones Anidados (Subconsulta con IN)
-- =======================================================
SELECT 
    C.Nombres + ' ' + C.Apellidos AS [Nombre del Cliente],
    CR.IdCredito AS [Numero de Credito]
FROM Operaciones.Creditos CR
INNER JOIN Operaciones.Clientes C ON CR.IdCliente = C.IdCliente
WHERE CR.IdVehiculo IN (
    -- La subconsulta extrae solo los IDs de vehículos viejos
    SELECT IdVehiculo 
    FROM Garantias.Vehiculos 
    WHERE Anio <= 2011
);
GO