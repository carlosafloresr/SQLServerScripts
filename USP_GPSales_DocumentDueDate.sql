USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_GPSales_DocumentDueDate]    Script Date: 4/27/2016 9:55:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GPSales_DocumentDueDate 'AIS', '16-22942'
*/
ALTER PROCEDURE [dbo].[USP_GPSales_DocumentDueDate]
              @Company      Varchar(5),
              @DocumentNo   Varchar(25)
AS
DECLARE       @Query        Varchar(1000)

SET @Query = N'SELECT CAST(DUEDATE AS Date) AS DUEDATE, SI.PortDischargeDate
FROM	' + RTRIM(@Company) + '.dbo.RM20101 RM
		LEFT JOIN GPCustom.dbo.SalesInvoices SI ON RM.CustNmbr = SI.CustomerId AND RM.DOCNUMBR = SI.InvoiceNumber AND SI.CompanyId = ''' + RTRIM(@Company) + '''
WHERE  DOCNUMBR = ''' + RTRIM(@DocumentNo) + '''
UNION
SELECT CAST(DUEDATE AS Date) AS DUEDATE, SI.PortDischargeDate
FROM	' + RTRIM(@Company) + '.dbo.RM30101 RM
		LEFT JOIN GPCustom.dbo.SalesInvoices SI ON RM.CustNmbr = SI.CustomerId AND RM.DOCNUMBR = SI.InvoiceNumber AND SI.CompanyId = ''' + RTRIM(@Company) + '''
WHERE  DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''''

EXECUTE(@Query)
