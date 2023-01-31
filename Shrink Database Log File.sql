DECLARE	@Server	Varchar(30)

SET @Server = @@SERVERNAME

PRINT @Server

--***********************************************************
--**                    I L S I N T 0 2                    **
--***********************************************************
IF @Server = 'ILSINT02'
BEGIN
	BEGIN TRY
		USE Integrations
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE Integrations
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE Integrations
		SET RECOVERY FULL;

		USE FI_Data;
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE FI_Data
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE FI_Data
		SET RECOVERY FULL;

		USE RCMR_Data;
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE RCMR_Data
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE RCMR_Data
		SET RECOVERY FULL;

		USE ReportServer;
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE ReportServer
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE ReportServer
		SET RECOVERY FULL;	

		USE TimeClockPlus;
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE TimeClockPlus
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE TimeClockPlus
		SET RECOVERY FULL;

		USE TimeClockPlusV5;
	
		-- Truncate the log by changing the database recovery model to SIMPLE.
		ALTER DATABASE TimeClockPlusV5
		SET RECOVERY SIMPLE;
	
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (2, 1);
	
		-- Reset the database recovery model.
		ALTER DATABASE TimeClockPlusV5
		SET RECOVERY FULL;
	END TRY
	BEGIN CATCH
		PRINT ''
	END CATCH
END

--***********************************************************
--**                    I L S G P 0 1                      **
--***********************************************************

IF @Server = 'ILSGP01'
BEGIN
	USE GPCustom;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE GPCustom
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE GPCustom
	SET RECOVERY FULL;


	USE IMC;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE IMC
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE IMC
	SET RECOVERY FULL;


	USE DNJ;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE DNJ
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE DNJ
	SET RECOVERY FULL;


	USE GIS;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE GIS
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE GIS
	SET RECOVERY FULL;


	USE FI;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE FI
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE FI
	SET RECOVERY FULL;


	USE RCMR;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE RCMR
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE RCMR
	SET RECOVERY FULL;


	USE IILS;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE IILS
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE IILS
	SET RECOVERY FULL;


	USE NDS;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE NDS
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE NDS
	SET RECOVERY FULL;


	USE [ABS];

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE [ABS]
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE [ABS]
	SET RECOVERY FULL;


	USE AIS;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE AIS
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE AIS
	SET RECOVERY FULL;


	USE RCCL;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE RCCL
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE RCCL
	SET RECOVERY FULL;


	USE Forecaster_AIS;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Forecaster_AIS
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Forecaster_AIS
	SET RECOVERY FULL;


	USE ILS_Datawarehouse;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE ILS_Datawarehouse
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE ILS_Datawarehouse
	SET RECOVERY FULL;
END

--***********************************************************
--**                    I L S S Q L 0 1                    **
--***********************************************************

IF @Server = 'ILSSQL01'
BEGIN
	USE Drivers;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Drivers
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Drivers
	SET RECOVERY FULL;


	USE DriverFiles;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE DriverFiles
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE DriverFiles
	SET RECOVERY FULL;


	USE EmployeeFiles;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE EmployeeFiles
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE EmployeeFiles
	SET RECOVERY FULL;


	USE Intranet;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Intranet
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Intranet
	SET RECOVERY FULL;


	USE Accounting;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Accounting
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Accounting
	SET RECOVERY FULL;


	USE Claims;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Claims
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Claims
	SET RECOVERY FULL;


	USE Insurance;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Insurance
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Insurance
	SET RECOVERY FULL;


	USE Vopes;

	-- Truncate the log by changing the database recovery model to SIMPLE.
	ALTER DATABASE Vopes
	SET RECOVERY SIMPLE;

	-- Shrink the truncated log file to 1 MB.
	DBCC SHRINKFILE (2, 1);

	-- Reset the database recovery model.
	ALTER DATABASE Vopes
	SET RECOVERY FULL;
END