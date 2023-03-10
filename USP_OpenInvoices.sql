USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_OpenInvoices]    Script Date: 06/10/2011 11:56:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_OpenInvoices 0, Null, 90, Null, 'IMC', 'CFLORES'
EXECUTE USP_OpenInvoices 0, Null, 90, '2363A', 'IMC', 'CFLORES'
EXECUTE AIS.dbo.USP_AROpenInvoices 0,90,Null,Null,'CFLORES'
*/
ALTER PROCEDURE [dbo].[USP_OpenInvoices]
		@OnlySummary	Bit = 0,
		@InvoiceNum		Varchar(30) = Null,
		@DueDays		Int = Null, 
		@Customer		Varchar(20) = Null,
		@Company		Varchar(5),
		@UserId			Varchar(25)
AS
DECLARE	@Query			Varchar(MAX)

IF @DueDays IS Null
	SET @DueDays = 90
	
SET	@Query = 'EXECUTE ' + @Company + '.dbo.USP_AROpenInvoices ' + CAST(@OnlySummary AS Char(1)) + ',' + CAST(@DueDays AS Varchar(5))

IF @Customer IS Null
	SET @Query = @Query + ',Null'
ELSE
	SET @Query = @Query + ',''' + @Customer + ''''
	
	
IF @InvoiceNum IS Null
	SET @Query = @Query + ',Null'
ELSE
	SET @Query = @Query + ',''' + @InvoiceNum + ''''
	
SET @Query = @Query + ',''' + @UserId + ''''

PRINT @Query
EXECUTE(@Query)