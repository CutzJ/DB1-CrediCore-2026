-- =========================================================================
-- Proyecto: CrediCore (Fase 1)
-- Script DDL Completo y Robusto
-- =========================================================================

-- 1. Limpieza segura de la base de datos si ya existe
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CrediCore')
BEGIN
    ALTER DATABASE CrediCore SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CrediCore;
END
GO

-- 2. Crear base de datos
CREATE DATABASE CrediCore;
GO

USE CrediCore;
GO

-- 3. Crear esquemas lógicos de negocio
CREATE SCHEMA Operaciones;
GO

CREATE SCHEMA Garantias;
GO

-- 4. Tabla de Clientes (Esquema Operaciones)
CREATE TABLE Operaciones.Clientes (
    IdCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    Correo VARCHAR(150) NOT NULL,
    DPI VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Clientes_DPI UNIQUE (DPI)
);
GO

-- 5. Tabla de Garantías Vehiculares (Esquema Garantias)
CREATE TABLE Garantias.Vehiculos (
    IdVehiculo INT IDENTITY(1,1) PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Anio INT NOT NULL,
    Color VARCHAR(30) NOT NULL,
    NumeroPlaca VARCHAR(20) NOT NULL,
    NumeroChasis VARCHAR(50) NOT NULL,
    
    -- Restricción CHECK: El año no puede ser menor a 2011 (máximo 15 años de antigüedad en 2026)
    CONSTRAINT CK_Vehiculos_Anio CHECK (Anio >= 2011),
    
    -- Restricción UNIQUE para Placa y Chasis
    CONSTRAINT UQ_Vehiculos_Placa UNIQUE (NumeroPlaca),
    CONSTRAINT UQ_Vehiculos_Chasis UNIQUE (NumeroChasis)
);
GO

-- 6. Tabla de Préstamos (Esquema Operaciones)
CREATE TABLE Operaciones.Creditos (
    IdCredito INT IDENTITY(1,1) PRIMARY KEY,
    IdCliente INT NOT NULL,
    IdVehiculo INT NOT NULL,
    MontoOtorgado DECIMAL(18,2) NOT NULL,
    TasaInteresMensual DECIMAL(5,2) NOT NULL,
    Estado VARCHAR(30) DEFAULT 'Activo' NOT NULL,
    FechaDesembolso DATETIME DEFAULT GETDATE() NOT NULL,
    
    -- Restricción CHECK: El monto debe ser estrictamente mayor a Q1,000 y tasa no negativa
    CONSTRAINT CK_Creditos_Monto CHECK (MontoOtorgado > 1000.00),
    CONSTRAINT CK_Creditos_Tasa CHECK (TasaInteresMensual >= 0.00)
);
GO

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