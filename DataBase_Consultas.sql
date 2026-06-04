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
    ColumnaEliminable NVARCHAR(255),
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

-- 6. Eliminación de objetos (DROP):

/* Eliminación de objetos solicitados (DROP):

Eliminar una tabla temporal.
Eliminar una restricción CHECK.
Eliminar una restricción UNIQUE.
Eliminar una columna.
Eliminar una tabla de pruebas.
Crear y eliminar una tabla Auditoria.
Crear y eliminar una tabla Logs.
Eliminar una FOREIGN KEY.
Eliminar una tabla MedicamentosPrueba.
Eliminar una base de datos de pruebas.

*/

-- Creación y eliminación de la tabla Auditoria 
-- (Se guardara en el esquema agendas para tener coherencia)

CREATE TABLE Agendas.Auditoria (
    AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
    Accion NVARCHAR(50),
    Usuario NVARCHAR(100),
    Fecha DATETIME DEFAULT GETDATE()
);

DROP TABLE Agendas.Auditoria;

-- Eliminar una restricción CHECK y una restricción UNIQUE
ALTER TABLE Personal.Medicos
DROP CONSTRAINT CK_Medicos_Salario;

ALTER TABLE Personal.Medicos
DROP CONSTRAINT UQ_Medicos_Correo;

-- Eliminar una columna no necesaria
ALTER TABLE Personal.Medicos
DROP COLUMN ColumnaEliminable;


-- Eliminar una tabla de pruebas y crear y eliminar una tablas Log y una tabla Auditoria.
CREATE TABLE Personal.MedicamentosPrueba (
    MedicamentoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Dosis NVARCHAR(50)
);

DROP TABLE Personal.MedicamentosPrueba;

CREATE TABLE Agendas.Logs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    Evento NVARCHAR(255),
    Usuario NVARCHAR(100),
    Fecha DATETIME DEFAULT GETDATE()
);

DROP TABLE Agendas.Logs;

Create table Personal.Auditoria (
    AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
    Accion NVARCHAR(50),
    Usuario NVARCHAR(100),
    Fecha DATETIME DEFAULT GETDATE()
);

DROP TABLE Personal.Auditoria;

-- Eliminar una FOREIGN KEY (FK entre Citas y Médicos)
ALTER TABLE Agendas.Citas
DROP CONSTRAINT FK_Citas_Medicos;

-- Eliminar una base de datos de pruebas
USE master;
GO

Create database HospitalDB_Pruebas;

Use Master;
Go

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'HospitalDB_Pruebas')
BEGIN
    ALTER DATABASE HospitalDB_Pruebas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalDB_Pruebas;
END
GO

-- Regresamos a la base de datos HospitalDB para seguir trabajando en ella.
use HospitalDB;
GO

-- 7. Insertación de datos de ejemplo.

/* Insertaciónes solicitadas:

Insertar 5 especialidades médicas.
Insertar 10 médicos.
Insertar 20 pacientes.
Insertar 15 citas.
Insertar 10 habitaciones.
Insertar 10 tratamientos.
Insertar 20 medicamentos.
Insertar pacientes con todos los campos.
Insertar médicos especialistas.
Insertar citas con fecha actual.
Insertar citas futuras.
Insertar habitaciones ocupadas.
Insertar habitaciones disponibles.
Insertar tratamientos activos.
Insertar tratamientos finalizados.

*/

-- Insertar 5 especialidades médicas
INSERT INTO Personal.Especialidades (Nombre) VALUES
('Cardiología'),
('Neurología'),
('Pediatría'),
('Dermatología'),
('Gastroenterología');

-- Insertar 10 médicos y especialistas
INSERT INTO Personal.Medicos (Nombre, EspecialidadID, Correo, Salario, Experiencia, Turno) VALUES
('Carlos Gómez', 1, 'CG@gmail.com', 4500.00, 5, 'Matutino'),
('María Rodríguez', 2, 'MR@gmail.com', 5200.00, 8, 'Vespertino'),
('Luis Fernández', 3, 'LF@gmail.com', 6000.00, 12, 'Nocturno'),
('Ana Martínez', 1, 'AM@gmail.com', 4800.00, 6, 'Matutino'),
('Pedro Sánchez', 4, 'PS@gmail.com', 5500.00, 9, 'Vespertino'),
('Sofía Ramírez', 5, 'SR@gmail.com', 4100.00, 3, 'Matutino'),
('Andrés Torres', 2, 'AT@gmail.com', 6800.00, 15, 'Nocturno'),
('Laura López', 3, 'LL@gmail.com', 5000.00, 7, 'Vespertino'),
('Diego Ramírez', 4, 'DR@gmail.com', 4300.00, 4, 'Matutino'),
('Marta Fernández', 5, 'MF@gmail.com', 5900.00, 11, 'Nocturno'),
('Jorge Sánchez', 1, 'JS@gmail.com', 7200.00, 20, 'Matutino'),
('Lucía Martínez', 2, 'LM@gmail.com', 4700.00, 5, 'Vespertino'),
('Elena Castro', 3, 'EC@gmail.com', 5300.00, 8, 'Matutino'),
('Ricardo Herrera', 4, 'RH@gmail.com', 6100.00, 13, 'Nocturno'),
('Claudia Vargas', 5, 'CV@gmail.com', 4200.00, 3, 'Vespertino'),
('Gabriel Mendoza', 1, 'GM@gmail.com', 5600.00, 10, 'Matutino'),
('Beatriz Ortiz', 2, 'BO@gmail.com', 7000.00, 18, 'Nocturno'),
('Alejandro Silva', 3, 'AS@gmail.com', 4900.00, 6, 'Vespertino'),
('Patricia Delgado', 4, 'PD@gmail.com', 4400.00, 4, 'Matutino'),
('Fernando Ríos', 5, 'FR@gmail.com', 7500.00, 22, 'Nocturno');

-- Insertar 20 pacientes con todos los campos (Nombre, Correo, Edad, Teléfono, Dirección, Género, Tipo de Sangre, Fecha de Nacimiento)
INSERT INTO Visitas.Pacientes (Nombre, Correo, Edad, Telefono, Direccion, Genero, TipoSangre, FechaNacimiento) VALUES
('Carlos Gómez', 'CG@gmail.com', 30, '555-1234', 'Calle 123', 'Masculino', 'O+', '1994-01-15'),
('María Rodríguez', 'MR@gmail.com', 25, '555-5678', 'Avenida 456', 'Femenino', 'A-', '1999-05-20'),
('Luis Fernández', 'LF@gmail.com', 40, '555-9012', 'Boulevard 789', 'Masculino', 'B+', '1984-03-10'),
('Ana Martínez', 'AM@gmail.com', 35, '555-3456', 'Calle 321', 'Femenino', 'AB-', '1989-07-25'),
('Pedro Sánchez', 'PS@gmail.com', 28, '555-7890', 'Avenida 654', 'Masculino', 'O-', '1996-11-05'),
('Sofía Ramírez', 'SR@gmail.com', 22, '555-2345', 'Boulevard 987', 'Femenino', 'A+', '2002-02-18'),
('Andrés Torres', 'AT@gmail.com', 45, '555-6789', 'Calle 456', 'Masculino', 'B-', '1979-09-30'),
('Laura López', 'LL@gmail.com', 32, '555-0123', 'Avenida 321', 'Femenino', 'AB+', '1992-12-12'),
('Diego Ramírez', 'DR@gmail.com', 27, '555-4567', 'Boulevard 654', 'Masculino', 'O+', '1997-04-22'),
('Marta Fernández', 'MF@gmail.com', 38, '555-8901', 'Calle 789', 'Femenino', 'A-', '1984-08-14'),
('Jorge Sánchez', 'JS@gmail.com', 50, '555-2345', 'Avenida 987', 'Masculino', 'B+', '1972-06-05'),
('Lucía Martínez', 'LM@gmail.com', 29, '555-6789', 'Boulevard 321', 'Femenino', 'AB-', '1993-10-30'),
('Elena Castro', 'EC@gmail.com', 31, '555-3450', 'Calle 159', 'Femenino', 'O+', '1993-04-05'),
('Ricardo Herrera', 'RH@gmail.com', 42, '555-7812', 'Avenida 753', 'Masculino', 'A+', '1982-11-12'),
('Claudia Vargas', 'CV@gmail.com', 26, '555-2398', 'Boulevard 852', 'Femenino', 'B-', '1998-08-24'),
('Gabriel Mendoza', 'GM@gmail.com', 36, '555-6745', 'Calle 963', 'Masculino', 'AB+', '1988-01-19'),
('Beatriz Ortiz', 'BO@gmail.com', 48, '555-0187', 'Avenida 147', 'Femenino', 'O-', '1976-05-14'),
('Alejandro Silva', 'AS@gmail.com', 33, '555-4521', 'Boulevard 369', 'Masculino', 'A-', '1991-09-02'),
('Patricia Delgado', 'PD@gmail.com', 24, '555-8963', 'Calle 258', 'Femenino', 'B+', '2000-12-08'),
('Fernando Ríos', 'FR@gmail.com', 55, '555-1274', 'Avenida link', 'Masculino', 'O+', '1969-07-21');

-- Insertar 15 citas con fecha actual y futuras
Insert into Agendas.Citas (PacienteID, MedicoID, HabitacionID, FechaCita, Estado, CostoConsulta) VALUES
(1, 1, 1, GETDATE(), 'Programada', 150.00),
(2, 2, 2, DATEADD(DAY, 7, GETDATE()), 'Programada', 200.00),
(3, 3, 3, DATEADD(DAY, 14, GETDATE()), 'Programada', 250.00),
(4, 4, 4, DATEADD(DAY, 21, GETDATE()), 'Programada', 300.00),
(5, 5, 5, DATEADD(DAY, 28, GETDATE()), 'Programada', 350.00),
(6, 6, 6, DATEADD(DAY, -7, GETDATE()), 'Completada', 150.00),
(7, 7, 7, DATEADD(DAY, -14, GETDATE()), 'Completada', 200.00),
(8, 8, 8, DATEADD(DAY, -21, GETDATE()), 'Completada', 250.00),
(9, 9, 9, DATEADD(DAY, -28, GETDATE()), 'Completada', 300.00),
(10, 10, 10, DATEADD(DAY, -35, GETDATE()), 'Completada', 350.00),
(11, 1, 1, DATEADD(DAY, -42, GETDATE()), 'Completada', 150.00),
(12, 2, 2, DATEADD(DAY, -49, GETDATE()), 'Completada', 200.00),
(13, 3, 3, DATEADD(DAY, -56 ,GETDATE()), 'Completada', 250.00),
(14 ,4 ,4 ,DATEADD(DAY,-63 ,GETDATE()) , 'Completada' ,300.00),
(15 ,5 ,5 ,DATEADD(DAY,-70 ,GETDATE()) , 'Completada' ,350.00);

-- Insertar 10 habitaciones ocupadas y disponibles
-- Nota: 0 para disponible y 1 para ocupado
INSERT INTO Agendas.Habitaciones (Numero, Tipo, Disponibilidad) VALUES
('101', 'Individual', 0),
('102', 'Doble', 1),
('103', 'Suite', 0),
('104', 'Individual', 1),
('105', 'Doble', 0),
('106', 'Suite', 1),
('107', 'Individual', 0),
('108', 'Doble', 1),
('109', 'Suite', 0),
('110', 'Individual', 1);

-- Insertar 10 tratamientos activos y finalizados
INSERT INTO Visitas.Tratamientos (PacienteID, Descripcion, FechaInicio, FechaFin) VALUES
(1, 'Tratamiento para hipertensión', DATEADD(DAY, -30, GETDATE()), NULL),
(2, 'Tratamiento para diabetes', DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -15, GETDATE())),
(3, 'Tratamiento para asma', DATEADD(DAY, -45, GETDATE()), NULL),
(4, 'Tratamiento para alergias', DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -5, GETDATE())),
(5, 'Tratamiento para artritis', DATEADD(DAY, -90, GETDATE()), NULL),
(6, 'Tratamiento para depresión', DATEADD(DAY, -120, GETDATE()), DATEADD(DAY, -30, GETDATE())),
(7, 'Tratamiento para migrañas', DATEADD(DAY, -15, GETDATE()), NULL),
(8, 'Tratamiento para insomnio', DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 10, GETDATE())),
(9, 'Tratamiento para ansiedad', DATEADD(DAY, -25, GETDATE()), NULL),
(10, 'Tratamiento para obesidad', DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, 30, GETDATE()));

-- Insertar 20 medicamentos
INSERT INTO Visitas.Medicamentos (TratamientoID, Nombre, Dosis) VALUES
(1, 'Lisinopril', '10 mg'),
(2, 'Metformina', '500 mg'),
(3, 'Albuterol', '2 inhalaciones'),
(4, 'Cetirizina', '10 mg'),
(5, 'Ibuprofeno', '400 mg'),
(6, 'Sertralina', '50 mg'),
(7, 'Sumatriptán', '100 mg'),
(8, 'Zolpidem', '10 mg'),
(9, 'Lorazepam', '1 mg'),
(10, 'Orlistat', '120 mg'),
(1, 'Amlodipino', '5 mg'),
(2, 'Glipizida', '5 mg'),
(3, 'Fluticasona', '2 inhalaciones'),
(4, 'Loratadina', '10 mg'),
(5, 'Naproxeno', '500 mg'),
(6, 'Fluoxetina', '20 mg'),
(7, 'Rizatriptán', '10 mg'),
(8, 'Eszopiclona', '3 mg'),
(9, 'Diazepam', '5 mg'),
(10, 'Sibutramina', '15 mg');

-- 8. Actualización de datos (UPDATE):

/* Actualizaciones solicitadas: 

Actualizar teléfono de un paciente.
Actualizar dirección de un paciente.
Actualizar salario de un médico.
Actualizar turno de un médico.
Cambiar estado de una cita.
Actualizar costo de consulta.
Actualizar nombre de especialidad.
Actualizar disponibilidad de habitación.
Actualizar tratamiento activo.
Actualizar medicamento.
Actualizar correo de paciente.
Actualizar correo de médico.
Actualizar fecha de cita.
Actualizar experiencia del médico.
Actualizar tipo de sangre.

*/

-- Actualizar teléfono y dirección de un paciente
UPDATE Visitas.Pacientes
SET Telefono = '555-9999', Direccion = 'Calle Nueva 123'
WHERE PacienteID = 1;

-- Actualizar salario y turno de un médico
UPDATE Personal.Medicos
SET Salario = 60000, Turno = 'Tarde'
WHERE MedicoID = 1;

-- Cambiar estado y costo de una cita
UPDATE Agendas.Citas
SET Estado = 'Completada', CostoConsulta = 180.00
WHERE CitaID = 1;

-- Actualizar nombre de especialidad
UPDATE Personal.Especialidades
SET Nombre = 'Cardiología Avanzada'
WHERE EspecialidadID = 1;

-- Actualizar disponibilidad de una habitación
UPDATE Agendas.Habitaciones
SET Disponibilidad = 1
WHERE HabitacionID = 2;

-- Actualizar tratamiento activo
UPDATE Visitas.Tratamientos
SET FechaFin = GETDATE()
WHERE TratamientoID = 1;

-- Actualizar medicamento
UPDATE Visitas.Medicamentos
SET Dosis = '20 mg'
WHERE MedicamentoID = 1;

-- Actualizar correo de un paciente
UPDATE Visitas.Pacientes
SET Correo = 'CG14@gmail.com'
WHERE PacienteID = 1;

-- Actualizar correo de un médico
UPDATE Personal.Medicos
SET Correo = 'JP34@Hospital.com'
WHERE MedicoID = 1;

-- Actualizar fecha de una cita
UPDATE Agendas.Citas
SET FechaCita = DATEADD(DAY, 3, GETDATE())
WHERE CitaID = 1;

-- Actualizar experiencia de un médico
UPDATE Personal.Medicos
SET Experiencia = 10
WHERE MedicoID = 1;

-- Actualizar tipo de sangre de un paciente
UPDATE Visitas.Pacientes
SET TipoSangre = 'A+'
WHERE PacienteID = 1;

-- 9. Eliminación de datos (DELETE):

/* Eliminaciones solicitadas: 

Eliminar un paciente específico.
Eliminar una cita.
Eliminar un medicamento.
Eliminar una habitación.
Eliminar un tratamiento.
Eliminar citas canceladas.
Eliminar pacientes sin citas.
Eliminar habitaciones vacías.
Eliminar medicamentos vencidos.
Eliminar registros de prueba.

*/

-- Eliminar un paciente específico
DELETE FROM Visitas.Pacientes
WHERE PacienteID = 1;

-- Eliminar una cita
DELETE FROM Agendas.Citas
WHERE CitaID = 1;

-- Eliminar un medicamento
DELETE FROM Visitas.Medicamentos
WHERE MedicamentoID = 1;

-- Eliminar una habitación
DELETE FROM Agendas.Habitaciones
WHERE HabitacionID = 2;

-- Eliminar un tratamiento
DELETE FROM Visitas.Tratamientos
WHERE TratamientoID = 1;

-- Eliminar citas canceladas
DELETE FROM Agendas.Citas
WHERE Estado = 'Cancelada';

-- Eliminar pacientes sin citas
DELETE FROM Visitas.Pacientes
WHERE PacienteID NOT IN (SELECT DISTINCT PacienteID FROM Agendas.Citas);

-- Eliminar habitaciones vacías
DELETE FROM Agendas.Habitaciones
WHERE Disponibilidad = 0;

-- Eliminar medicamentos vencidos (suponiendo que un medicamento se considera vencido si su tratamiento ha finalizado hace más de 30 días)
DELETE FROM Visitas.Medicamentos
WHERE TratamientoID IN (
    SELECT TratamientoID
    FROM Visitas.Tratamientos
    WHERE FechaFin IS NOT NULL AND DATEDIFF(DAY, FechaFin, GETDATE()) > 30
);

-- Eliminar registros de prueba (suponiendo que los registros de prueba tienen un nombre específico o un patrón en el correo)
DELETE FROM Visitas.Pacientes
WHERE Nombre LIKE 'Prueba%';

DELETE FROM Personal.Medicos
WHERE Nombre LIKE 'Prueba%';

-- 9. Consultas de selección (SELECT):

/* Consultas solicitadas:

Mostrar todos los pacientes.
Mostrar todos los médicos.
Mostrar todas las especialidades.
Mostrar todas las citas.
Mostrar pacientes ordenados por apellido.
Mostrar médicos ordenados por salario.
Mostrar citas del día actual.
Mostrar habitaciones disponibles.
Mostrar cantidad de pacientes registrados.
Mostrar cantidad de citas por médico.

*/

-- Mostrar todos los pacientes
SELECT * FROM Visitas.Pacientes;

-- Mostrar todos los médicos
SELECT * FROM Personal.Medicos;

-- Mostrar todas las especialidades
SELECT * FROM Personal.Especialidades;

-- Mostrar todas las citas
SELECT * FROM Agendas.Citas;

-- Mostrar pacientes ordenados por apellido (suponiendo que el apellido es la última palabra en el campo Nombre)
SELECT * FROM Visitas.Pacientes
ORDER BY RIGHT(Nombre, CHARINDEX(' ', REVERSE(Nombre)) - 1);

-- Mostrar médicos ordenados por salario
SELECT * FROM Personal.Medicos
ORDER BY Salario DESC;

-- Mostrar citas del día actual
SELECT * FROM Agendas.Citas
WHERE CAST(FechaCita AS DATE) = CAST(GETDATE() AS DATE);

-- Mostrar habitaciones disponibles
SELECT * FROM Agendas.Habitaciones
WHERE Disponibilidad = 0;

-- Mostrar cantidad de pacientes registrados
SELECT COUNT(*) AS CantidadPacientes FROM Visitas.Pacientes;

-- Mostrar cantidad de citas por médico
SELECT MedicoID, COUNT(*) AS CantidadCitas
FROM Agendas.Citas
GROUP BY MedicoID;