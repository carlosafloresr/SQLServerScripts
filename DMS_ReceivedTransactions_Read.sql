/*
EXECUTE DMS_ReceivedTransactions_Read '1002134', 2
*/
ALTER PROCEDURE DMS_ReceivedTransactions_Read
		@BatchId	Varchar(25),
		@Status		Int = 0
AS
DECLARE @Act_Interchange	Char(4),
		@Act_Lifts			Char(4),
        @Act_Storage		Char(4),
        @Act_Misc			Char(4),
        @Act_Total			Varchar(15),
		@CompanyNum			Int,		
		@Company			Varchar(5)

SET @CompanyNum = (SELECT TOP 1 Cmpy_No FROM View_DMS_ReceivedTransactions WHERE Batch_No = @BatchId)
SET @Company = (SELECT CompanyId FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyNumber = @CompanyNum AND IsTest = 0)
SET @Act_Interchange = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'DMS_INTERCHANGES' AND Company = @Company)
SET @Act_Lifts = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'DMS_LIFTS' AND Company = @Company)
SET @Act_Storage = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'DMS_STORAGE' AND Company = @Company)
SET @Act_Misc = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'DMS_MISC' AND Company = @Company)
SET @Act_Total = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE ParameterCode = 'DMS_TOTAL' AND Company = @Company)

SELECT	DMS.*,
		LEFT(RTRIM(DMS.GLPre), 1) + '-' + RIGHT(RTRIM(DMS.GLPre), 2) + '-' + @Act_Interchange AS Act_Interchange,
		LEFT(RTRIM(DMS.GLPre), 1) + '-' + RIGHT(RTRIM(DMS.GLPre), 2) + '-' + @Act_Lifts AS Act_Lifts,
		LEFT(RTRIM(DMS.GLPre), 1) + '-' + RIGHT(RTRIM(DMS.GLPre), 2) + '-' + @Act_Storage AS Act_Storage,
		LEFT(RTRIM(DMS.GLPre), 1) + '-' + RIGHT(RTRIM(DMS.GLPre), 2) + '-' + @Act_Misc AS Act_Misc,
		@Act_Total AS Act_Total
FROM	View_DMS_ReceivedTransactions DMS
WHERE	DMS.Batch_No = @BatchId
		AND TotalCharge <> 0 
		AND Status = @Status