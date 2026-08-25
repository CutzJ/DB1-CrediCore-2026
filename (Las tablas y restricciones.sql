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