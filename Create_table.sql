--CREATE DATABASE lab2_1;
--GO

USE lab2_1;
GO
DROP TABLE dbo.Timetable; 
DROP TABLE dbo.Troutes; 
DROP TABLE dbo.Train_routes; 
DROP TABLE dbo.Delays; 
DROP TABLE dbo.Train_employees; 
DROP TABLE dbo.Trains;
DROP TABLE dbo.Employees; 
DROP TABLE dbo.Distances; 
DROP TABLE dbo.Stations;  

GO
--создание таблицы станций
CREATE TABLE Stations(
	id_station INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	name_station NVARCHAR(50) NOT NULL 
);

--создание таблицы расстояний между станциями
CREATE TABLE Distances (
	id_station1 INT REFERENCES Stations (id_station),
	id_station2 INT REFERENCES Stations (id_station),
	distance INT NOT NULL
	PRIMARY KEY (id_station1, id_station2),
);

--создание таблицы поездов
CREATE TABLE Trains(
	num INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	category NVARCHAR(50) NOT NULL,
	quantity INT NOT NULL CHECK(quantity >=0),
	id_station INT NOT NULL REFERENCES Stations(id_station),
	r_num INT NOT NULL 
);

--создание таблицы расписание
CREATE TABLE Timetable (
	id INT NOT NULL,
	id_train  INT NOT NULL REFERENCES Trains (num) ON DELETE CASCADE,
	id_station INT NOT NULL REFERENCES Stations(id_station),
	arrival_time SMALLDATETIME NOT NULL, --1955-12-13 12:43:00
	departure_time SMALLDATETIME NOT NULL,
	direction BIT NOT NULL,
	tickets INT NOT NULL CHECK(tickets>=0),
	PRIMARY KEY(id, id_train, id_station), 
	CONSTRAINT CHK_Timetable CHECK(arrival_time < departure_time)
);

--создание таблицы сотрудников
CREATE TABLE Employees(
	id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	name NVARCHAR(30) NOT NULL,
	surname NVARCHAR(50) NOT NULL,
	position NVARCHAR(50) NOT NULL,
	station_id INT NOT NULL FOREIGN KEY REFERENCES Stations(id_station)
);

--создание таблицы поезда-сотрудники
CREATE TABLE Train_employees(
	num INT NOT NULL FOREIGN KEY REFERENCES Trains(num),
	id INT NOT NULL FOREIGN KEY REFERENCES Employees(id),
	PRIMARY KEY(num,id),
);

--создание таблицы задержки
CREATE TABLE Delays (
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_train INT NOT NULL REFERENCES Trains(num) ON DELETE CASCADE,
	arrival_time SMALLDATETIME NOT NULL,
	direction BIT NOT NULL,
	delay INT NOT NULL
);

--создание таблицы маршрутов
CREATE TABLE Train_routes(
	r_num INT NOT NULL,
	id_station INT NOT NULL FOREIGN KEY REFERENCES Stations(id_station),
	order_stations INT NOT NULL,
	PRIMARY KEY(r_num,id_station)
);

--создание таблицы транзитные маршруты
CREATE TABLE Troutes (
	id_troute int NOT NULL,
	id_station int ,
	order_num int NOT NULL,
	r_num int NOT NULL, 
	PRIMARY KEY (id_Troute, id_station, r_num),
	FOREIGN KEY (r_num, id_station) REFERENCES Train_routes(r_num, id_station),
	CONSTRAINT CHK_Troutes CHECK(id_troute != r_num)
);

GO

