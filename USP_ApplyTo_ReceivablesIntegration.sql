USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_ApplyTo_ReceivablesIntegration]    Script Date: 5/15/2020 12:11:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_ApplyTo_ReceivablesIntegration 'ATEST', '4770', 'C27-120568', '27-120568', 1054.75, '04/03/2018', '2345'
*/
ALTER PROCEDURE [dbo].[USP_ApplyTo_ReceivablesIntegration]
		@Company		Varchar(5),
		@CustomerId		Varchar(20),
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@Amount			Numeric(10,2),
		@PostingDate	Date,
		@NatAccount		Varchar(20) = Null,
		@WriteOffAmnt	Numeric(10,2) = 0
AS
DECLARE	@Query			Varchar(1000)

IF @WriteOffAmnt IS Null
	SET @WriteOffAmnt = 0

SET @PostingDate = IIF(@PostingDate < '01/01/1980', GETDATE(), @PostingDate)

SET @Query = N'EXECUTE ' + RTRIM(@Company) + '.dbo.USP_ApplyTo_Receivables ''' + RTRIM(@CustomerId) + ''',''' + RTRIM(@ApplyFrom) + ''','''
SET @Query = @Query + RTRIM(@ApplyTo) + ''',' + CAST(@Amount AS Varchar) + ',''' + CAST(@PostingDate AS Varchar) + ''''

IF @NatAccount IS NOT Null
	SET @Query = @Query + ',''' + RTRIM(@NatAccount) + ''''
ELSE
	SET @Query = @Query + ',Null'

SET @Query = @Query + ',' + CAST(@WriteOffAmnt AS Varchar)

--PRINT @Query
EXECUTE(@Query)
