USE CrediCore;
GO

/* =========================================================================
   FASE 2.2: INGESTA DE CLIENTES MEDIANTE FÓRMULAS OFIMÁTICAS (EXCEL)
   Sentencias DML generadas mediante la concatenación dinámica:
   =CONCATENAR("INSERT INTO Operaciones.Clientes (Nombres, Apellidos, DPI, 
   Telefono, Direccion) VALUES ('", A2, "', '", B2, "', '", C2, "', '", D2, "', '", E2, "');")
   ========================================================================= */

-- Pegar aquí las 500 sentencias generadas desde tu archivo Excel
INSERT INTO Operaciones.Clientes (Nombres, Apellidos, DPI, Telefono, Direccion) VALUES ('Juan', 'Perez', '1000000000001', '50000001', 'Ciudad de Guatemala');
INSERT INTO Operaciones.Clientes (Nombres, Apellidos, DPI, Telefono, Direccion) VALUES ('Maria', 'Lopez', '1000000000002', '50000002', 'Mixco');
INSERT INTO Operaciones.Clientes (Nombres, Apellidos, DPI, Telefono, Direccion) VALUES ('Carlos', 'Gomez', '1000000000003', '50000003', 'Villa Nueva');
-- ... [Resto de las 500 sentencias generadas desde el Excel] ...

GO

-- Verificación de volumen
SELECT COUNT(*) AS TotalClientes FROM Operaciones.Clientes;
GO