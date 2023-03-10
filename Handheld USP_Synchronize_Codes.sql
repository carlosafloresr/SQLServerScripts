USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_Synchronize_Codes]    Script Date: 08/01/2012 8:08:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
******************************************
Synchronize Server Codes Codes with the 
local database
******************************************
EXECUTE USP_Synchronize_Codes
******************************************
*/
ALTER PROCEDURE [dbo].[USP_Synchronize_Codes]
AS
DECLARE	@SERVERONLINE Bit

BEGIN TRY
     SELECT @SERVERONLINE = ServerRunning 
     FROM	ILSINT02.FI_Data.dbo.ServerRunning
END TRY
BEGIN CATCH
     SET @SERVERONLINE = 0
END CATCH

IF @SERVERONLINE = 1
BEGIN
	EXECUTE USP_Synchronize_DamageCodes
	EXECUTE USP_Synchronize_JobCodes
	EXECUTE USP_Synchronize_RepairCodes
	
	TRUNCATE TABLE SubCategories
	
	INSERT INTO SubCategories
	SELECT	*
	FROM	ILSINT02.FI_Data.dbo.SubCategories
	
	TRUNCATE TABLE Positions
	
	INSERT INTO Positions
	SELECT	*
	FROM	ILSINT02.FI_Data.dbo.Positions
	
	TRUNCATE TABLE Locations
	
	INSERT INTO Locations 
			(Location
			,SubLocation
			,CustomerNumber
			,Prefix)
	SELECT	Location
			,SubLocation
			,CustomerNumber
			,Prefix
	FROM	ILSINT02.FI_Data.dbo.Locations
	
	TRUNCATE TABLE CodeRelations
	
	INSERT INTO CodeRelations (RelationType, ParentCode, ChildCode, Category, SubCategory)
	SELECT	RelationType, ParentCode, ChildCode, Category, SubCategory
	FROM	ILSINT02.FI_Data.dbo.CodeRelations

	SELECT	*
	INTO	#tmpMech
	FROM	ILSINT02.FI_Data.dbo.Mech

	UPDATE	Mech
	SET		FName		 = #tmpMech.FName,
			LName		= #tmpMech.LName,
			Depot_Loc	= #tmpMech.Depot_Loc,
			Active		= #tmpMech.Active,
			Password	= #tmpMech.Password
	FROM	#tmpMech
	WHERE	Mech.Mech_No = #tmpMech.Mech_No

	INSERT INTO Mech
	SELECT	*
	FROM	#tmpMech
	WHERE	Mech_No NOT IN (SELECT Mech_No FROM Mech)

	DROP TABLE #tmpMech

	SELECT	*
	INTO	#tmpTranslation
	FROM	ILSINT02.FI_Data.dbo.Translation

	UPDATE	Translation
	SET		FormName	= #tmpTranslation.FormName, 
			ObjectName	= #tmpTranslation.ObjectName, 
			English		= #tmpTranslation.English, 
			Spanish		= #tmpTranslation.Spanish
	FROM	#tmpTranslation
	WHERE	RTRIM(Translation.FormName) + '_' + RTRIM(Translation.ObjectName) = RTRIM(#tmpTranslation.FormName) + '_' + RTRIM(#tmpTranslation.ObjectName)

	INSERT INTO Translation (FormName, ObjectName, English, Spanish)
	SELECT	FormName, ObjectName, English, Spanish
	FROM	#tmpTranslation
	WHERE	RTRIM(FormName) + '_' + RTRIM(ObjectName) NOT IN (SELECT RTRIM(FormName) + '_' + RTRIM(ObjectName) FROM Translation)

	DROP TABLE #tmpTranslation

	SELECT	Depot, Depot_Loc, Location, Use_Mech, Prefix
	INTO	#tmpDepots
	FROM	ILSINT02.FI_Data.dbo.Depots

	INSERT INTO Depots
	SELECT	Depot, Depot_Loc, Location, Use_Mech, Prefix
	FROM	#tmpDepots
	WHERE	Depot NOT IN (SELECT Depot FROM Depots)

	DROP TABLE #tmpDepots

	SELECT	Acct_No, Acct_Name, Sales, Inactive
	INTO	#tmpCustomers
	FROM	ILSINT02.FI_Data.dbo.Customers

	UPDATE	Customers
	SET		Acct_Name	= #tmpCustomers.Acct_Name, 
			Sales		= #tmpCustomers.Sales, 
			Inactive	= #tmpCustomers.Inactive
	FROM	#tmpCustomers
	WHERE	Customers.Acct_No = #tmpCustomers.Acct_No

	INSERT INTO Customers
		(Acct_No,
		 Acct_Name,
		 Sales,
		 Inactive)
	SELECT	Acct_No, Acct_Name, Sales, Inactive
	FROM	#tmpCustomers
	WHERE	Acct_No NOT IN (SELECT Acct_No FROM Customers)

	DROP TABLE #tmpCustomers
END