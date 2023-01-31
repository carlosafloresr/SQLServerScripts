/*
******************************************
Synchronize Server Customers with the 
local database
******************************************
EXECUTE USP_Synchronize_Customers
******************************************
*/
CREATE PROCEDURE USP_Synchronize_Customers
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
	INSERT INTO Customers
	SELECT	Acct_No,
			Acct_Name
	FROM	ILSINT02.FI_Data.dbo.Accounts
	WHERE	Acct_No NOT IN (SELECT Acct_No FROM Customers)
END