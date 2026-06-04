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

-- 5. Alteraciones en tablas

/* Modificación de estructuras solicitadas (ALTER):

Agregar columna teléfono a Pacientes.
Agregar columna dirección a Pacientes.
Agregar columna género.
Agregar columna tipo_sangre.
Agregar columna fecha_nacimiento.
Modificar tamaño del campo nombre.
Modificar tamaño del campo dirección.
Agregar columna experiencia a Médicos.
Agregar columna turno.
Agregar columna observaciones.
Eliminar columna observaciones.
Agregar columna estado a Citas.
Agregar columna costo_consulta.
Modificar tipo de dato del costo.
Agregar columna disponibilidad a Habitaciones.

*/

-- Alteraciones en la tabla Pacientes (Telefono, Dirección, Género, Tipo de Sangre, Fecha de Nacimiento)
ALTER TABLE Visitas.Pacientes
ADD Telefono NVARCHAR(20),
    Direccion NVARCHAR(255),
    Genero NVARCHAR(10),
    TipoSangre NVARCHAR(5),
    FechaNacimiento DATE;

-- Modificación del tamaño del campo Nombre y Dirección en Pacientes:
Alter TABLE Visitas.Pacientes
ALTER COLUMN Nombre NVARCHAR(150) NOT NULL;

Alter TABLE Visitas.Pacientes
ALTER COLUMN Direccion NVARCHAR(500);

-- Alteraciones en la tabla Médicos (Experiencia, Turno, Observaciones)
ALTER TABLE Personal.Medicos
ADD Experiencia INT,
    Turno NVARCHAR(20),
    Observaciones NVARCHAR(255);

-- Eliminación de la columna Observaciones en Médicos
ALTER TABLE Personal.Medicos
DROP COLUMN Observaciones;

-- Alteraciones en la tabla Citas (Estado, Costo Consulta)
ALTER TABLE Agendas.Citas
ADD Estado NVARCHAR(20),
    CostoConsulta DECIMAL(18, 2);

-- Modificación del tipo de dato del costo de consulta a FLOAT
ALTER TABLE Agendas.Citas
ALTER COLUMN CostoConsulta FLOAT;

-- Alteraciones en la tabla Habitaciones (Disponibilidad)
ALTER TABLE Agendas.Habitaciones
ADD Disponibilidad BIT;

