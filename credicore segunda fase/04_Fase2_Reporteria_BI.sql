USE CrediCore;
GO

/* =========================================================================
   FASE 2.4: REPORTERÍA ANALÍTICA E INTELIGENCIA DE NEGOCIOS (BI)
   Consultas de consolidación, exposición crediticia e integridad referencial.
   ========================================================================= */

-- REPORTE 1: Resumen Ejecutivo de Cartera y Exposición por Estado
SELECT 
    Estado,
    COUNT(IdCredito) AS TotalPrestamos,
    SUM(MontoOtorgado) AS MontoTotalColocado,
    AVG(MontoOtorgado) AS TicketPromedio,
    AVG(TasaInteresMensual) AS TasaPromedioMensual
FROM Operaciones.Creditos
GROUP BY Estado
ORDER BY MontoTotalColocado DESC;
GO

-- REPORTE 2: Top 10 Clientes con Mayor Monto Financiado (Riesgo Concentrado)
SELECT TOP 10
    c.IdCliente,
    CONCAT(c.Nombres, ' ', c.Apellidos) AS Cliente,
    c.DPI,
    c.Telefono,
    COUNT(cr.IdCredito) AS TotalCreditosActivos,
    SUM(cr.MontoOtorgado) AS CapitalTotalOtorgado
FROM Operaciones.Clientes c
INNER JOIN Operaciones.Creditos cr ON c.IdCliente = cr.IdCliente
GROUP BY c.IdCliente, c.Nombres, c.Apellidos, c.DPI, c.Telefono
ORDER BY CapitalTotalOtorgado DESC;
GO

-- REPORTE 3: Análisis de Garantías Prendarias por Marca de Vehículo
SELECT 
    v.Marca,
    COUNT(cr.IdCredito) AS TotalVehiculosEnGarantia,
    SUM(CASE WHEN cr.Estado = 'Mora' THEN 1 ELSE 0 END) AS CreditosEnMora,
    SUM(cr.MontoOtorgado) AS MontoTotalGarantizado
FROM Garantias.Vehiculos v
INNER JOIN Operaciones.Creditos cr ON v.IdVehiculo = cr.IdVehiculo
GROUP BY v.Marca
ORDER BY TotalVehiculosEnGarantia DESC;
GO

-- REPORTE 4: Reporte Integral de Cobranza (Cartera en Mora con Detalle Prendario)
SELECT TOP 20
    cr.IdCredito,
    CONCAT(c.Nombres, ' ', c.Apellidos) AS Deudor,
    c.Telefono,
    CONCAT(v.Marca, ' ', v.Modelo, ' (', v.Anio, ')') AS VehiculoGarantia,
    v.NumeroPlaca,
    cr.MontoOtorgado,
    cr.FechaDesembolso
FROM Operaciones.Creditos cr
INNER JOIN Operaciones.Clientes c ON cr.IdCliente = c.IdCliente
INNER JOIN Garantias.Vehiculos v ON cr.IdVehiculo = v.IdVehiculo
WHERE cr.Estado = 'Mora'
ORDER BY cr.MontoOtorgado DESC;
GO