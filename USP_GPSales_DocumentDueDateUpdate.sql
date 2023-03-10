USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPSales_DocumentDueDateUpdate]    Script Date: 4/26/2016 2:14:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPSales_DocumentDueDateUpdate 'AIS', '16-22942', '07/31/2015', '08/30/2015', 'CFLORES'
EXECUTE USP_GPSales_DocumentDueDate 'AIS', '16-22942'
*/
ALTER PROCEDURE [dbo].[USP_GPSales_DocumentDueDateUpdate]
              @Company				Varchar(5),
              @DocumentNo			Varchar(25),
              @DueDate				Date = Null,
			  @PortDischargeDate	Date = Null,
			  @UserId				Varchar(25) = Null
AS
DECLARE       @Query				Varchar(1500),
              @DCStatus				Smallint,
			  @SalesInvoiceId		Int

DECLARE	@TblData TABLE
		(DocNumbr	Varchar(30),
		CustNmbr	Varchar(30),
		DocDate		Date)

DECLARE @tblDocStatus TABLE (DocStatus Smallint)

SET @Query = N'SELECT DCSTATUS FROM  ' + RTRIM(@Company) + '.dbo.RM00401 WHERE DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''

INSERT INTO @tblDocStatus
EXECUTE(@Query)

SELECT @DCStatus = DocStatus FROM @tblDocStatus

IF @DueDate IS NOT Null
BEGIN
	IF @DCStatus = 2
	BEGIN
		   SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.RM20101 SET DUEDATE = ''' + CONVERT(Char(10), @DueDate, 101) +  
									  ''' WHERE DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''
		   EXECUTE(@Query)
	END
	ELSE
	BEGIN
		   SET @Query = N'UPDATE ' + RTRIM(@Company) + '.dbo.RM30101 SET DUEDATE = ''' + CONVERT(Char(10), @DueDate, 101) + 
									  ''' WHERE DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''
		   EXECUTE(@Query)
	END
END

IF @PortDischargeDate IS NOT Null
BEGIN
	SET @SalesInvoiceId = (SELECT TOP 1 SalesInvoiceId FROM SalesInvoices WHERE CompanyId = @Company AND InvoiceNumber = @DocumentNo ORDER BY CreatedOn DESC)

	IF @DCStatus = 2
	BEGIN
		SET @Query = N'SELECT DOCNUMBR, CUSTNMBR, DOCDATE FROM ' + RTRIM(@Company) + '.dbo.RM20101 WHERE DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''
	END
	ELSE
	BEGIN
		SET @Query = N'SELECT DOCNUMBR, CUSTNMBR, DOCDATE FROM ' + RTRIM(@Company) + '.dbo.RM30101 WHERE DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''
	END

	INSERT INTO @TblData
	EXECUTE(@Query)

	IF @SalesInvoiceId IS Null
	BEGIN
		INSERT INTO SalesInvoices
				(CompanyId,
				InvoiceNumber,
				InvoiceDate,
				CustomerId,
				RecordType,
				ItemLine,
				ItemCode,
				CreatedBy,
				PortDischargeDate)
		SELECT	@Company,
				DocNumbr,
				DocDate,
				CustNmbr,
				'I',
				16384,
				'INV',
				@UserId,
				@PortDischargeDate
		FROM	@TblData
	END
	ELSE
	BEGIN
		UPDATE	SalesInvoices
		SET		PortDischargeDate = @PortDischargeDate
		WHERE	SalesInvoiceId = @SalesInvoiceId
	END
END