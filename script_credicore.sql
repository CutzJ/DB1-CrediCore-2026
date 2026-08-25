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

