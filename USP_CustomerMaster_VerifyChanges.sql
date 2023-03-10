USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CustomerMaster_VerifyChanges]    Script Date: 8/18/2017 9:28:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CustomerMaster_VerifyChanges
*/
ALTER PROCEDURE [dbo].[USP_CustomerMaster_VerifyChanges]
AS
DECLARE	@Company	Varchar(5),
		@Query		Varchar(MAX)

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RTRIM(CompanyId)
FROM	Companies
WHERE	SWSCustomers = 1

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'INSERT INTO CustomerMaster
		   (CompanyId,
			CustNmbr,
			CustName,
			CustClas,
			Address1,
			Address2,
			City,
			State,
			Zip,
			Phone1,
			Inactive,
			PymTrmId,
			PymTrmDays,
			Hold,
			CntCprsn,
			Changed,
			Trasmitted,
			ChangedBy,
			Result)
	SELECT	''' + @Company + ''',
			CustNmbr,
			CustName,
			CustClas,
			Address1,
			Address2,
			City,
			State,
			Zip,
			Phone1,
			Inactive,
			GP.PymTrmId,
			ISNULL(SY.DUEDTDS,30) AS PymTrmDays,
			Hold,
			CntCprsn,
			CAST(1 AS Bit) AS Changed,
			CAST(0 AS Bit) AS Trasmitted,
			'''' AS ChangedBy,
			'''' AS Result
	FROM	' + @Company + '.dbo.RM00101 GP
			LEFT JOIN ' + @Company + '.dbo.SY03300 SY ON GP.PYMTRMID = SY.PYMTRMID
	WHERE	CustNmbr NOT IN (SELECT CustNmbr FROM CustomerMaster WHERE CompanyId = ''' + @Company + ''') AND
			CustName <> '''''

	EXECUTE(@Query)

	SET @Query = N'UPDATE	CustomerMaster
		SET		CustomerMaster.CustName		= DATA.CustName,
				CustomerMaster.CustClas		= DATA.CustClas,
				CustomerMaster.Address1		= DATA.Address1,
				CustomerMaster.Address2		= DATA.Address2,
				CustomerMaster.City			= DATA.City,
				CustomerMaster.State		= DATA.State,
				CustomerMaster.Zip			= DATA.Zip,
				CustomerMaster.Phone1		= DATA.Phone1,
				CustomerMaster.Inactive		= DATA.Inactive,
				CustomerMaster.PymTrmId		= DATA.PymTrmId,
				CustomerMaster.PymTrmDays	= DATA.PymTrmDays,
				CustomerMaster.Hold			= DATA.Hold,
				CustomerMaster.CntCprsn		= DATA.CntCprsn,
				CustomerMaster.Changed		= 1,
				CustomerMaster.Trasmitted	= 0
		FROM	(
				SELECT	GP.*,
						ISNULL(SY.DUEDTDS,30) AS PymTrmDays
				FROM	' + @Company + '.dbo.RM00101 GP
						LEFT JOIN ' + @Company + '.dbo.SY03300 SY ON GP.PYMTRMID = SY.PYMTRMID
						INNER JOIN CustomerMaster CU ON GP.CUSTNMBR = CU.CUSTNMBR AND CU.CompanyId = ''' + @Company + '''
				WHERE	GP.CustName <> CU.CustName
						OR GP.Address1 <> CU.Address1
						OR GP.Address2 <> CU.Address2
						OR GP.City <> CU.City
						OR GP.CustClas <> CU.CustClas
						OR GP.State <> CU.State
						OR GP.Zip <> CU.Zip
						OR GP.Phone1 <> CU.Phone1
						OR GP.Inactive <> CU.Inactive
						OR GP.Hold <> CU.Hold
						OR GP.CntCprsn <> CU.CntCprsn
						OR GP.PYMTRMID <> CU.PYMTRMID
				) DATA
		WHERE	CustomerMaster.CUSTNMBR = DATA.CUSTNMBR
				AND CustomerMaster.CompanyId = ''' + @Company + ''''

	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

