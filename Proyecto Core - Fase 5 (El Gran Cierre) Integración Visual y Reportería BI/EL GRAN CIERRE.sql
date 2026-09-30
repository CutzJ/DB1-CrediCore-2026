-- =========================================================================
-- Proyecto: CrediCore (Fase FINAL)
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
-- 1. Crear el Login a nivel de servidor
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'usr_cajero')
BEGIN
    CREATE LOGIN usr_cajero WITH PASSWORD = 'PasswordSeguro2026!', CHECK_POLICY = OFF;
END
GO

-- 2. Crear el Usuario a nivel de la base de datos CrediCore
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'usr_cajero')
BEGIN
    CREATE USER usr_cajero FOR LOGIN usr_cajero;
END
GO

-- 3. Asignar los permisos estrictamente necesarios (Principio de mínimo privilegio)
-- Si la vista está en el esquema Operaciones:
GRANT SELECT ON Operaciones.vw_AtencionAlCliente TO usr_cajero;
GRANT EXECUTE ON Operaciones.SP_ProcesarPago TO usr_cajero;

-- (O si estuvieran en dbo, descomenta estas dos):
-- GRANT SELECT ON dbo.vw_AtencionAlCliente TO usr_cajero;
-- GRANT EXECUTE ON dbo.SP_ProcesarPago TO usr_cajero;
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

-- Crear la tabla HistorialPagos para que el Procedimiento Almacenado funcione
CREATE TABLE Operaciones.HistorialPagos (
    IdPago INT IDENTITY(1,1) PRIMARY KEY,
    IdCredito INT,
    Monto DECIMAL(18,2),
    FechaPago DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IdCredito) REFERENCES Operaciones.Creditos(IdCredito) 
);
GO

-- Creación del Trigger de Auditoría
CREATE TRIGGER Operaciones.TRG_Auditoria_Creditos_TasaInteres
ON Operaciones.Creditos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validamos si el UPDATE afectó la columna de la tasa de interés
    IF UPDATE(TasaInteresMensual)
    BEGIN
        -- Insertamos el registro en la tabla de Logs
        INSERT INTO Auditoria.Logs_Creditos (Accion, ValorAnterior, ValorNuevo, FechaHora)
        SELECT 
            'Modificación de Tasa de Interés en Crédito #' + CAST(i.IdCredito AS VARCHAR(10)),
            d.TasaInteresMensual, 
            i.TasaInteresMensual, 
            GETDATE()
        FROM 
            inserted i
        INNER JOIN 
            deleted d ON i.IdCredito = d.IdCredito
        -- Condición clave: Solo registrar si el número realmente cambió
        WHERE i.TasaInteresMensual <> d.TasaInteresMensual;
    END
END;
GO

CREATE SCHEMA Auditoria;
GO

-- 2. Crear la tabla de Bitácora para el Trigger
CREATE TABLE Auditoria.Logs_Creditos (
    IdLog INT IDENTITY(1,1) PRIMARY KEY,
    Accion VARCHAR(255),
    ValorAnterior DECIMAL(10,2), 
    ValorNuevo DECIMAL(10,2),
    FechaHora DATETIME DEFAULT GETDATE()
);
GO