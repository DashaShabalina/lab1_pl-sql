USE lab2_1;
GO

--���������� ������� �������
BEGIN
DECLARE @number_stations INT = 3000
DECLARE @id INT
--��������� ���� �� � ������� ��� �����-�� ������
Select @id = ISNULL(MAX(id_station) + 1,1) FROM Stations
--PRINT @id
SET @number_stations = @number_stations + @id
while @id < @number_stations 
	BEGIN
		SET @id = @id + 1
		--PRINT 'station' + Convert(nvarchar,@id)
		INSERT INTO Stations VALUES (CONCAT('station',@id))
	END
END;

GO

--���������� ������� ���������� ����� ���������
INSERT INTO Distances(id_station1, id_station2, distance)
	SELECT TOP 50000 St1.id_station, St2.id_station , CONVERT(int,RAND(CHECKSUM(NEWID()))*150+2)
	FROM Stations St1,Stations St2 
	WHERE St1.id_station<St2.id_station
	ORDER BY NEWID()

GO

--���������� ������� ���������
BEGIN
DECLARE @count_routes INT = 5000 -- ����� ���������    
DECLARE @max_route_length INT  --������������ ����� ��������
DECLARE @id INT

--��������� ���� �� � ������� ��������� ��� ������
SELECT @id = ISNULL(MAX(r_num), 0) + 1 FROM Train_routes
--PRINT '������������ ����� ������ � ������� ' + CONVERT(nvarchar,@max_route_id)
--������ ������������ ���������� ����� ���������
DECLARE @max_dist int = (SELECT MAX(id_station1) FROM Distances)
SET @count_routes =  @id + @count_routes 

WHILE @id < @count_routes
	BEGIN
		SET @max_route_length = 10
		--�������� ��������� ����� ������� ��� ��������
		DECLARE @current_station INT = (SELECT TOP 1 id_station1 FROM Distances WHERE RAND() * @max_dist <= id_station1)
		DECLARE @order INT=1 
		INSERT INTO Train_routes VALUES(@id,@current_station,@order)
		--print 'id ' + Convert(nvarchar,@id) + ' station ' +  Convert(nvarchar,@current_station) + ' order ' + Convert(nvarchar,@order)
		SET @max_route_length = @max_route_length-1
		--������� �������
		WHILE @max_route_length!=0
			begin
				set @current_station = 
				(SELECT TOP 1 id_station2 FROM Distances 
					WHERE RAND() * 
						(SELECT MAX(id_station2) FROM Distances WHERE id_station1=@current_station) 
							<= id_station2 AND id_station1 = @current_station );
				if (@current_station is null)  break 
				else 
					begin
						SET @order=@order+1
						SET @max_route_length = @max_route_length - 1
						--print 'id ' + Convert(nvarchar,@id) + ' station ' +  Convert(nvarchar,@current_station) + ' order ' + Convert(nvarchar,@order)
						INSERT INTO Train_routes VALUES(@id,@current_station,@order)
					end
			end
		SET @id = @id + 1
	END
END;

GO

--���������� ������� �������
BEGIN
DECLARE @count_trains INT = 1000 --���������� �������
DECLARE @quantity INT; --���������� ���� � ������
DECLARE @id INT
DECLARE @Categories TABLE (id INT IDENTITY(1,1) PRIMARY KEY, categories NVARCHAR(30));
INSERT INTO @Categories VALUES ('passenger'), ('freight'), ('military');

--��������� ���� �� � ������� ��������� ��� ������
SELECT @id = ISNULL(MAX(num) + 1,1) FROM Trains
SET @count_trains = @count_trains + @id
	
WHILE @id < @count_trains
	BEGIN
		SET @quantity = CAST(RAND() * 100 as int);
		--print @quantity
		INSERT INTO Trains(category,quantity,id_station,r_num)
		SELECT categories,@quantity,id_station,r_num FROM 
		(SELECT TOP 1 categories FROM @Categories WHERE RAND() * 3 <= id )t,
		(SELECT TOP 1 id_station,r_num FROM Train_routes WHERE RAND() * (SELECT MAX(r_num) FROM Train_routes) <= r_num)t1
		SET @id = @id + 1;
	END

DELETE FROM @Categories;
END;

GO

--���������� ������� ����������
BEGIN
DECLARE @Girls TABLE (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(40))
DECLARE @Men TABLE (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(40))
DECLARE @Surnames TABLE (id INT IDENTITY(1,1) PRIMARY KEY, surname NVARCHAR(40))
DECLARE @Positions TABLE (id INT IDENTITY(1,1) PRIMARY KEY, positions NVARCHAR(40))
DECLARE @Stations TABLE (id_st INT)
DECLARE @id_st INT = 1

INSERT INTO @Girls VALUES
('Dasha'), ('Masha'), ('Sasha'), ('Nastya'),('Anya'),
('Tonya'),('Lera'),('Vika'),('Galya'),('Dina');
INSERT INTO @Men VALUES
('Yura'),('Stas'),('Styopa'),('Timofey'),('Semyon'),
('Ruslan'),('Roman'),('Oleg'),('Mikhail'),('Lev');
INSERT INTO @Surnames VALUES
('Abramson'),('Adamson'),('Black'),('Brooks'),('Cook');
INSERT INTO @Positions VALUES
('conductor'),('driver'),('dispatcher'),('station master'),
('engineer'),('director'),('driver assistant'),('electromechanic');

DECLARE @max_id_station INT = (SELECT MAX(id_station) FROM Stations)

WHILE @id_st <= 100
	BEGIN
		INSERT INTO @Stations(id_st)
		(SELECT TOP 1 id_station FROM Stations
		WHERE RAND() * @max_id_station <= id_station)
		SET @id_st =  @id_st + 1
	END

INSERT INTO  Employees (name,surname,position,station_id) -- 400 400 94
	SELECT * FROM (
		SELECT name,surname,positions,id_st 
		FROM @Stations, @Girls CROSS JOIN @Surnames CROSS JOIN @Positions  
		UNION ALL 
		SELECT name ,surname,positions,id_st FROM @Stations,@Men CROSS JOIN @Surnames CROSS JOIN @Positions)t
ORDER BY NEWID();

DELETE FROM @Girls;
DELETE FROM @Men;
DELETE FROM @Surnames;
DELETE FROM @Positions;
DELETE FROM @Stations;
END;

GO

--���������� ������� ������-����������
BEGIN
DECLARE @i INT = 0
DECLARE @a INT, @b INT
WHILE @i < 1000
	begin
		SET @a=(SELECT TOP 1 num FROM Trains
		WHERE RAND()*(SELECT MAX(num) FROM Trains) <= Trains.num)
		SET @b=(SELECT TOP 1 id FROM Employees
		WHERE RAND()*(SELECT MAX(id) FROM Employees)<= Employees.id)
		INSERT INTO Train_employees VALUES (@a,@b)
		SET @i = @i + 1
	end
END;
GO

--���������� ������� ���������� ���������
BEGIN
DECLARE @count_troutes INT = 10 --���������� ���������� ���������
DECLARE @troute_id INT --������� ����� ����������� ��������
DECLARE @max_route_length INT --������������ ����� ����������� ��������
DECLARE @cursor CURSOR
DECLARE @Route_table table (num INT IDENTITY(1,1) PRIMARY KEY, id INT) --��������,������� ����� � ����������
DECLARE @Troutes TABLE (id_troute INT, id_station INT, order_num INT, r_num INT)
--DECLARE @Temp_troutes TABLE (id_troute INT, id_station INT, order_num INT, r_num INT)

--��������� ���� �� ��� ������ � �������
SELECT @troute_id = ISNULL(MAX(id_troute),0) + 1 FROM Troutes
SET @count_troutes = @count_troutes + @troute_id

--������� ������������ ������� � ��������� � ������������ �������
DECLARE @max_station int = (SELECT MAX(id_station) FROM Train_routes) 
DECLARE @max_route int = (SELECT MAX(r_num) FROM Train_routes)

WHILE @troute_id < @count_troutes
	BEGIN
		DECLARE @current_station INT
		DECLARE @current_route INT
		DECLARE @order INT
		SET @max_route_length = RAND()*5+2
		--�������� ������ ������� � ������� �� ������� ������
		SELECT TOP 1 @current_route = r_num, @current_station = id_station, @order = order_stations FROM Train_routes 
			WHERE RAND() * @max_station <= id_station AND RAND() * @max_route <= r_num AND order_stations!=1
		SET @max_route_length = @max_route_length - 1
		print '-------------��������� �������-------------'
		print 'route ' + Convert(nvarchar,@current_route) + ' station ' +  Convert(nvarchar,@current_station) + 
				' order ' + Convert(nvarchar,@order)
		
		--������� � ������� �������,������� ��� ��������, ����� �� �����������
		INSERT INTO @Route_table VALUES (@current_route) 
		--���������� ������ � ������
		SET @cursor = CURSOR SCROLL FOR
		SELECT r_num , id_station, order_stations FROM Train_routes
		WHERE r_num = @current_route and order_stations <= @order
	
		print '-------------� ������� �� ���������� ��������-------------'
		OPEN @cursor
		FETCH NEXT FROM @cursor INTO @current_route,@current_station,@order
		WHILE @@FETCH_STATUS = 0 
			BEGIN
			PRINT Convert(nvarchar,@current_route) + ' and ' +  Convert(nvarchar,@current_station) + ' and ' + Convert(nvarchar,@order)
			--INSERT INTO @Temp_troutes VALUES(@troute_id, @current_station, @order,@current_route)
			INSERT INTO Troutes VALUES(@troute_id, @current_station, @order,@current_route)
			FETCH NEXT FROM @cursor INTO @current_route,@current_station,@order
		END
		print '-------------------------------------------------'
	
	DECLARE @flag INT = 1 --���� ���������� ���������� �� ��������� �������
	WHILE @max_route_length !=0
		BEGIN
			--SELECT * FROM @Route_table
			DECLARE @tmp_current_route INT ,@tmp_current_station INT ,@tmp_order INT, @oreder_new INT, @route_new INT = 0
			DECLARE @tmp_cursor CURSOR

			--�������� ������� �� ������� ���������
			--�� �� ������ ��������� � ��� ����������� ����������
			--�� ������ ��������� �� �������, ������� � �������� ���������
			--��������� ��� � ����������� �������� �� ��������� ������� ������ ���� ���� ���������
			SELECT TOP 1 @route_new = r_num, @current_station = id_station, @order = order_stations 
				FROM Train_routes 
					WHERE id_station = @current_station 
							and (r_num not in (SELECT id FROM @Route_table)) 
							--and RAND() * @max_station <= id_station 
							--and RAND() * @max_route <= r_num

			if (@route_new = 0) 
				BEGIN
					print '������ ���������'
					break
				END

			if (@order = (SELECT MAX(order_stations) FROM Train_routes WHERE r_num = @route_new))
				BEGIN
					INSERT INTO @Route_table VALUES (@route_new) 
					print '������� ������� ��� ������� ��������� ���������'
					print 'route ' + Convert(nvarchar,@route_new) + ' station ' +  Convert(nvarchar,@current_station) + 
				' order ' + Convert(nvarchar,@order)
					CONTINUE
				END
							
			print '-------------����� �������-------------'
			print 'route ' + Convert(nvarchar,@route_new) + ' station ' +  Convert(nvarchar,@current_station) + 
				' order ' + Convert(nvarchar,@order)
			INSERT INTO @Route_table VALUES (@route_new) 


			--�������� ����� ������� ���������
			SELECT TOP 1 @current_station = id_station, @oreder_new = order_stations FROM Train_routes
			WHERE r_num = @route_new and order_stations > @order 
			ORDER BY NEWID();
			print '����� ������� ��������� ' + Convert(nvarchar,@current_station) + ' �� ������� � �������� '+ Convert(nvarchar,@oreder_new)

			--��������� ������ ������� �� @order �� @oreder_new
			SET @tmp_cursor = CURSOR SCROLL FOR
				SELECT  r_num , id_station, order_stations FROM Train_routes
					WHERE r_num = @route_new and (order_stations BETWEEN @order AND @oreder_new)

			print '-------------� ������� �� ������ ��������-------------'
			OPEN @tmp_cursor
			FETCH NEXT FROM @tmp_cursor INTO @tmp_current_route,@tmp_current_station,@tmp_order

			WHILE @@FETCH_STATUS = 0 
				BEGIN
					print 'route ' + Convert(nvarchar,@tmp_current_route) + ' station ' +  Convert(nvarchar,@tmp_current_station) + 
						' order ' + Convert(nvarchar,@tmp_order)
						--INSERT INTO @Temp_troutes VALUES(@troute_id, @tmp_current_station, @tmp_order,@tmp_current_route)
						INSERT INTO Troutes VALUES(@troute_id, @tmp_current_station, @tmp_order,@tmp_current_route)
					FETCH NEXT FROM @tmp_cursor INTO @tmp_current_route,@tmp_current_station,@tmp_order
				END
			print '-------------------------------------------------'
			CLOSE @tmp_cursor
			DEALLOCATE @tmp_cursor
			SET @max_route_length = @max_route_length - 1
		END
	SET @troute_id = @troute_id + 1
	CLOSE @cursor
	DEALLOCATE @cursor
	DELETE FROM @Route_table
	END
	--DELETE FROM @Temp_troutes  
	--WHERE id_troute in(
	--SELECT DISTINCT id_troute FROM 
	--(SELECT id_troute,id_station,order_num, r_num, MAX(length_troute) OVER ( PARTITION BY id_troute)  as length_troute  FROM 
	--(SELECT id_troute,id_station,order_num, r_num, DENSE_RANK() OVER ( PARTITION BY id_troute Order by r_num DESC ) as length_troute 
	--FROM @Temp_troutes )t)t1 WHERE length_troute=1)	

	DELETE FROM Troutes 
	WHERE id_troute in(
	SELECT DISTINCT id_troute FROM 
	(SELECT id_troute,id_station,order_num, r_num, MAX(length_troute) OVER ( PARTITION BY id_troute)  as length_troute  FROM 
	(SELECT id_troute,id_station,order_num, r_num, DENSE_RANK() OVER ( PARTITION BY id_troute Order by r_num DESC ) as length_troute 
	FROM Troutes)t)t1 WHERE length_troute=1)	

	SELECT * FROM Troutes
END;

GO

--���������� ������� ����������
BEGIN
DECLARE @count INT = 1 --���������� ��������� � ���������� �������� 4000
DECLARE @id INT
DECLARE @cursor CURSOR
DECLARE @id_train INT
DECLARE @route INT
DECLARE @direction BIT
DECLARE @tickets INT
/*DECLARE @Temp_timetable TABLE 
	(id INT NOT NULL, 
	id_train  INT NOT NULL ,
	id_station INT NOT NULL ,
	arrival_time SMALLDATETIME NOT NULL, --�����-�����-��� ����-������-PM/AM
	departure_time SMALLDATETIME NOT NULL,
	direction BIT NOT NULL,
	tickets INT NOT NULL CHECK(tickets>=0),
	PRIMARY KEY(id, id_train, id_station))
	*/
DECLARE @current_date SMALLDATETIME = CONVERT (SMALLDATETIME, SYSDATETIME())
PRINT 'current_date ' + Convert(nvarchar,@current_date)
--PRINT @current_date

--��������� ���� � ������� ������
SELECT @id = ISNULL(MAX(id),0) + 1 FROM Timetable


WHILE @count < 4000
	BEGIN
		--�������� �����
		SET @id_train = (SELECT TOP 1 num FROM Trains
							WHERE RAND()*(SELECT MAX(num) FROM Trains) <= num)
		PRINT 'train : ' + Convert(nvarchar,@id_train)
		--���������� ���������� ������� ����
		SET @tickets = RAND() * (SELECT quantity FROM Trains
									WHERE num = @id_train)

		PRINT 'tickets : ' + Convert(nvarchar,@tickets)
		--�������� �������
		SET @route = (SELECT TOP 1 r_num FROM Trains
							WHERE num = @id_train)
		PRINT 'route : ' + Convert(nvarchar,@route)
		--�������� ����������� : 1 - �� �������� , 0 - � �������� �������
		SET @direction = Convert(INT,RAND() * 2)
		if (@direction = 2) SET @direction = 1
		PRINT 'direction : ' + Convert(nvarchar,@direction)

		--���������� ������ � ������
		if (@direction = 0)
			BEGIN
				SET @cursor = CURSOR SCROLL FOR
				SELECT id_station FROM Train_routes
				WHERE r_num = @route 
				ORDER BY order_stations DESC
			END
		else 
			BEGIN
				SET @cursor = CURSOR SCROLL FOR
				SELECT id_station FROM Train_routes
				WHERE r_num = @route 
			END

		DECLARE @station INT
		
		--�������� ��������� ���� ����������� ������, ������� ������ ���� ����� ������� ����
			--��������� ��������� ���������� ����� 
			--�������� ��� ����� � ������� ����
			
		DECLARE @departure_time SMALLDATETIME = DATEADD(hour, RAND() * 999, @current_date)
		PRINT '����� ����������� ��� ��������' + Convert(nvarchar,@id) + ' : ' + Convert(nvarchar,@departure_time)
		DECLARE @arrival_time SMALLDATETIME = DATEADD(minute, -30, @departure_time)
		PRINT '����� ������ ������� ��� ��������' + Convert(nvarchar,@id) + ' : ' + Convert(nvarchar,@arrival_time)
		PRINT ' '
		OPEN @cursor
		FETCH NEXT FROM @cursor INTO @station
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				--INSERT INTO  @Temp_timetable VALUES(@id,@id_train,@station,@arrival_time,@departure_time,@direction,@tickets)
				INSERT INTO  Timetable VALUES(@id,@id_train,@station,@arrival_time,@departure_time,@direction,@tickets)
				PRINT 'id ' + Convert(nvarchar,@id)  + ' ������� ' + Convert(nvarchar,@station) + ' ����� ' + Convert(nvarchar,@id_train) +
					' ����� �������� ' + Convert(nvarchar,@arrival_time) + ' ����� ����������� ' + Convert(nvarchar,@departure_time) +
					' ����������� ' + Convert(nvarchar,@direction) + ' ���������� ������� ���� ' + Convert(nvarchar,@tickets)
				SET @arrival_time = DATEADD(minute, RAND() * 300 + 60, @departure_time)
				SET @departure_time = DATEADD(minute, RAND() * 45 + 15, @arrival_time)
				SET @tickets = RAND() * (SELECT quantity FROM Trains WHERE num = @id_train)
				FETCH NEXT FROM @cursor INTO @station
			END
		CLOSE @cursor
		DEALLOCATE @cursor
		SET @id = @id + 1
		SET @count = @count + 1 
	END
	SELECT * FROM Timetable
	--DELETE @Temp_timetable
END;

GO

--���������� ������� ��������

GO
