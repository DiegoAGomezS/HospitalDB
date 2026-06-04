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

-- 4. Crear las tablas con sus respectivas columnas, tipos de datos y restricciones.

/* Información a tener en cuenta al crear las tablas:

Restricciones:

Definir PRIMARY KEY en Pacientes.
Definir PRIMARY KEY en Médicos.
Agregar NOT NULL al nombre del paciente.
Agregar NOT NULL al nombre del médico.
Crear una restricción UNIQUE para el correo del paciente.
Crear una restricción UNIQUE para el correo del médico.
Agregar CHECK para edad mayor o igual a 0.
Agregar CHECK para salario del médico mayor que 0.
Agregar DEFAULT para fecha de registro.
Crear FOREIGN KEY entre Médicos y Especialidades.
Crear FOREIGN KEY entre Citas y Pacientes.
Crear FOREIGN KEY entre Citas y Médicos.
Crear FOREIGN KEY entre Tratamientos y Pacientes.
Crear FOREIGN KEY entre Medicamentos y Tratamientos.
Crear FOREIGN KEY entre Habitaciones y Pacientes.

*/

-- Tabla de Médicos y Especialidades
CREATE TABLE Personal.Especialidades (
    EspecialidadID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Personal.Medicos (
    MedicoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    EspecialidadID INT,
    Correo NVARCHAR(255) UNIQUE,
    Salario DECIMAL(18, 2) CHECK (Salario > 0),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (EspecialidadID) REFERENCES Personal.Especialidades(EspecialidadID)
);

-- Tabla de Pacientes, Tratamientos y Medicamentos
CREATE TABLE Visitas.Pacientes (
    PacienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Correo NVARCHAR(255) UNIQUE,
    Edad INT CHECK (Edad >= 0),
    FechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Visitas.Tratamientos (
    TratamientoID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT,
    Descripcion NVARCHAR(255),
    FechaInicio DATETIME,
    FechaFin DATETIME,
    FOREIGN KEY (PacienteID) REFERENCES Visitas.Pacientes(PacienteID)
);

CREATE TABLE Visitas.Medicamentos (
    MedicamentoID INT PRIMARY KEY IDENTITY(1,1),
    TratamientoID INT,
    Nombre NVARCHAR(100),
    Dosis NVARCHAR(50),
    FOREIGN KEY (TratamientoID) REFERENCES Visitas.Tratamientos(TratamientoID)
);

-- Tabla de Citas y Habitaciones
CREATE TABLE Agendas.Habitaciones (
    HabitacionID INT PRIMARY KEY IDENTITY(1,1),
    Numero NVARCHAR(50) NOT NULL UNIQUE,
    Tipo NVARCHAR(50)
);

CREATE TABLE Agendas.Citas (
    CitaID INT PRIMARY KEY IDENTITY(1,1),
    PacienteID INT,
    MedicoID INT,
    HabitacionID INT,
    FechaCita DATETIME,
    FOREIGN KEY (PacienteID) REFERENCES Visitas.Pacientes(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Personal.Medicos(MedicoID),
    FOREIGN KEY (HabitacionID) REFERENCES Agendas.Habitaciones(HabitacionID)
);

