-- =========================================================================
-- 7. PRUEBAS DE ESTRÉS Y VALIDACIÓN DE RESTRICCIONES (Errores esperados)


-- Prueba 1: Violación de CHECK en Garantías (Vehículo menor al año 2011) -> DEBE FALLAR
INSERT INTO Garantias.Vehiculos (Marca, Modelo, Anio, Color, NumeroPlaca, NumeroChasis) 
VALUES ('Toyota', 'Yaris', 2005, 'Rojo', 'P999ERR', 'CHASISFASEDIECIOCHO01');
GO

-- Prueba 2: Violación de CHECK en Créditos (Monto menor o igual a Q1,000) -> DEBE FALLAR
INSERT INTO Operaciones.Creditos (IdCliente, IdVehiculo, MontoOtorgado, TasaInteresMensual) 
VALUES (1, 1, 500.00, 2.50);
GO


-- =========================================================================
-- 8. INSERCIÓN DE DATOS VÁLIDOS (Registros de prueba)


-- Clientes válidos
INSERT INTO Operaciones.Clientes (Nombres, Apellidos, Telefono, Correo, DPI) VALUES
('Juan Carlos', 'Pérez Gómez', '55551234', 'juan.perez@example.com', '1234567890101'),
('María Fernanda', 'López Ruiz', '44445678', 'maria.lopez@example.com', '2345678901012'),
('Carlos Alberto', 'Mendoza Soto', '33339012', 'carlos.mendoza@example.com', '3456789010123');
GO

-- Vehículos válidos (Año >= 2011, Placa y Chasis únicos)
INSERT INTO Garantias.Vehiculos (Marca, Modelo, Anio, Color, NumeroPlaca, NumeroChasis) VALUES
('Toyota', 'Corolla', 2018, 'Gris', 'P123ABC', 'CHASISABC123456789'),
('Honda', 'Civic', 2020, 'Negro', 'P234DEF', 'CHASISDEF987654321'),
('Mazda', 'CX-5', 2015, 'Rojo', 'P345GHI', 'CHASISGHI456789123');
GO

-- Créditos válidos (Monto > 1000, Tasa >= 0)[cite: 2]
INSERT INTO Operaciones.Creditos (IdCliente, IdVehiculo, MontoOtorgado, TasaInteresMensual) VALUES
(1, 1, 25000.00, 2.50),
(2, 2, 45000.50, 1.80),
(3, 3, 15000.00, 3.00);
GO


-- =========================================================================
-- 9. CONSULTAS DE VERIFICACIÓN (SELECT)

SELECT * FROM Operaciones.Clientes;
SELECT * FROM Garantias.Vehiculos;
SELECT * FROM Operaciones.Creditos;
GO