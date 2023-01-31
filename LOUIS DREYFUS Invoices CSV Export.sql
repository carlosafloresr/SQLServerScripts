DECLARE @Query		Varchar(4000),
		@DateIni	Date = dbo.DayFwdBack(GETDATE(), 'P', 'Saturday')

SET @Query = N'SELECT REPLACE(CMP.CompanyName, '', '', '' '') AS Company,FSI.CustomerNumber,
		FSI.InvoiceNumber,
		FSI.BillToRef,
		CAST(FSI.InvoiceDate AS Date) AS InvoiceDate,
		CAST(FSI.DueDate AS Date) AS DueDate,
		CAST(FSI.DeliveryDate AS Date) AS DeliveryDate,
		FSI.AccessorialTotal,
		FSI.InvoiceTotal,
		FSI.Equipment
FROM	PRISQL004P.Integrations.dbo.View_Integration_FSI FSI
		INNER JOIN Companies CMP ON FSI.Company = CMP.CompanyId
WHERE	FSI.Company = ''GIS''
		AND FSI.WeekEndDate >= ''' + CAST(@DateIni AS Varchar) + '''
		AND FSI.CustomerNumber IN (''16440w'',''16440'',''16440A'')'

--EXECUTE USP_Create_CSV_File_From_Query @Query, '\\D5J5MW52\TEMP\DLP_GIS_Invoices_June.csv'
--PRINT @Query
EXECUTE(@Query)