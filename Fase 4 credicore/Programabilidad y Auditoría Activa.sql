-- Aseguramos que estamos en la BD correcta
USE CrediCore;
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

-- Creación de la vista para ocultar datos sensibles
CREATE VIEW Operaciones.vw_AtencionAlCliente AS
SELECT 
    c.Nombres + ' ' + c.Apellidos AS [Nombre del Cliente],
    cr.IdCredito AS [Numero de Credito],
    v.Marca AS [Marca del Vehiculo],
    cr.Estado AS [Estado del Credito],
    cr.MontoOtorgado AS [Saldo Actual]
FROM 
    Operaciones.Clientes c
INNER JOIN 
    Operaciones.Creditos cr ON c.IdCliente = cr.IdCliente
INNER JOIN 
    Garantias.Vehiculos v ON cr.IdVehiculo = v.IdVehiculo;
GO

SELECT * FROM Operaciones.vw_AtencionAlCliente;

--************************************************************************************
--Parte B: Lógica de Negocio Segura.


CREATE PROCEDURE Operaciones.SP_ProcesarPago
    @IdCredito INT,
    @MontoAbono DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciamos la transacción de forma segura
        BEGIN TRAN;

        DECLARE @SaldoActual DECIMAL(18,2);

        -- Obtenemos el saldo (MontoOtorgado) y bloqueamos la fila momentáneamente 
        -- para evitar que otra transacción la modifique al mismo tiempo
        SELECT @SaldoActual = MontoOtorgado
        FROM Operaciones.Creditos WITH (UPDLOCK)
        WHERE IdCredito = @IdCredito;

        -- Validación estricta de negocio: El abono no puede superar el saldo
        IF @MontoAbono > @SaldoActual
        BEGIN
            -- THROW lanza el error, detiene la ejecución y salta al bloque CATCH
            THROW 51000, 'Error: El monto de abono es mayor al saldo actual del crédito. Operación denegada.', 1;
        END

        -- 1. Insertamos el registro del pago en la tabla de historial
        INSERT INTO Operaciones.HistorialPagos (IdCredito, Monto, FechaPago)
        VALUES (@IdCredito, @MontoAbono, GETDATE());

        -- 2. Actualizamos el saldo principal restando el abono
        UPDATE Operaciones.Creditos
        SET MontoOtorgado = MontoOtorgado - @MontoAbono
        WHERE IdCredito = @IdCredito;

        -- Si llegamos aquí sin que haya saltado ningún error, guardamos los cambios definitivamente
        COMMIT TRAN;
        PRINT 'Pago procesado exitosamente y saldo actualizado.';

    END TRY
    BEGIN CATCH
        -- Si ocurre un error, entramos aquí y deshacemos cualquier cambio a medias
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRAN;
        END

        -- Le devolvemos el mensaje de error al usuario
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
--Prueba 1: El Escudo en Acción (Prueba Fallida)
EXEC Operaciones.SP_ProcesarPago @IdCredito = 1, @MontoAbono = 1000000.00;

--Prueba 2: El Pago Exitoso
EXEC Operaciones.SP_ProcesarPago @IdCredito = 1, @MontoAbono = 500.00;

--************************************************************************************
--Parte C: El Auditor Silencioso (Triggers).
--1. Haz el cambio malicioso:
UPDATE Operaciones.Creditos SET TasaInteresMensual = 1 WHERE IdCredito = 1;

--Atrapa al infractor:
SELECT * FROM Auditoria.Logs_Creditos;