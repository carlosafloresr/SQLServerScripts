DECLARE	@PayrollWeek	Date = '02/10/2018',
		@BatchId		Varchar(25),
		@Company		Varchar(5) = 'IMC',
		@GLAccount		Varchar(20) = '0-00-2792'

DECLARE	@tblFuel Table (
		VendorId		Varchar(12),
		Amount			Numeric(10,2),
		GLAccount		Varchar(20),
		Description		Varchar(40))

SET @BatchId = 'FUEL-' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + dbo.PADL(DAY(@PayrollWeek), 2, '0') + dbo.PADL(YEAR(@PayrollWeek), 4, '0')

DELETE	Integrations_AP
WHERE	Integration = 'FUEL'
		AND BatchId = @BatchId
		AND Company = @Company

DELETE	ReceivedIntegrations
WHERE	Integration = 'FUEL'
		AND BatchId = @BatchId
		AND Company = @Company

/*
="INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('"&A2&"',"&B2&",'0-00-2050','FUEL 02/10')"
*/

INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50792',804.93,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50786',266.77,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50797',543.78,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50783',435.18,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50793',449.7,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50779',298.52,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50795',1047.57,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50782',409.56,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50784',358.34,'0-00-2050','FUEL 02/10')
INSERT INTO @tblFuel (VendorId, Amount, GLAccount, Description) VALUES ('I50790',1522.96,'0-00-2050','FUEL 02/10')

INSERT INTO @tblFuel
SELECT	VendorId, 
		Amount, 
		@GLAccount AS GLAccount, 
		Description
FROM	@tblFuel

INSERT INTO [dbo].[Integrations_AP]
		([Integration]
		,[Company]
		,[BatchId]
		,[VCHNUMWK]
		,[VENDORID]
		,[DOCNUMBR]
		,[DOCTYPE]
		,[DOCAMNT]
		,[DOCDATE]
		,[PSTGDATE]
		,[PORDNMBR]
		,[CHRGAMNT]
		,[TEN99AMNT]
		,[PRCHAMNT]
		,[TRXDSCRN]
		,[CURNCYID]
		,[RATETPID]
		,[EXCHDATE]
		,[RATEEXPR]
		,[CREATEDIST]
		,[DISTTYPE]
		,[ACTNUMST]
		,[DEBITAMT]
		,[CRDTAMNT]
		,[DISTREF]
		,[RecordId])
SELECT	'FUEL' AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		'FUEL-' + RTRIM(VendorId) + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + dbo.PADL(DAY(@PayrollWeek), 2, '0') + RIGHT(dbo.PADL(YEAR(@PayrollWeek), 4, '0'), 2) AS VoucherNumber,
		VendorId,
		'WE ' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(@PayrollWeek), 2, '0') + ' FUEL ' + RTRIM(VendorId) AS DocumentNumber,
		5 AS DocType,
		Amount AS DocAmount,
		@PayrollWeek AS DocDate,
		CAST(GETDATE() AS Date) AS PstgDate,
		Null AS PONumber,
		Amount AS ChargeAmount,
		Amount AS Ten99,
		Amount AS PurchAmount,
		'Fuel ' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(@PayrollWeek), 2, '0') AS Description,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		CASE WHEN GLAccount = '0-00-2050' THEN 2 ELSE 6 END AS DisType,
		GLAccount AS AccountNumber,
		CASE WHEN GLAccount = '0-00-2050' THEN Amount ELSE 0 END AS Debit,
		CASE WHEN GLAccount = '0-00-2792' THEN Amount ELSE 0 END AS Credit,
		'Fuel ' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(@PayrollWeek), 2, '0') AS Description,
		0
FROM	@tblFuel
ORDER BY VendorId

INSERT INTO ReceivedIntegrations(Integration, Company, BatchId) VALUES ('FUEL', @Company, @BatchId)