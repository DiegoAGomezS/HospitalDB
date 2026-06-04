use master
go

-- 1. Crear la base de datos "HospitalDB".
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HospitalDB')
BEGIN
    ALTER DATABASE HospitalDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalDB;
END
GO

CREATE DATABASE HospitalDB;
GO

-- 2. Mostrar todas las bases de datos en el sistema

select * from sys.databases;
GO

-- 3. Seleccionar la base de datos "HospitalDB" para trabajar en ella.
USE HospitalDB;
GO

-- 3.5. Discutir los esquemas a crear para dividir la base de datos en áreas funcionales.

Create schema Personal -- Información relacionada a los Médicos y sus especialidades.
go

Create schema Visitas -- Información relacionada a los pacientes, como info personal, tratamientos y medicamentos.
go

Create schema Agendas -- Información relacionada a las citas médicas y Habitaciones en las que se dieron dichas citas.
go

