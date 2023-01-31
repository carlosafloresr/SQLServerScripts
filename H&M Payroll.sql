DECLARE	@Integration	Varchar(10) = 'OOPAY',
		@Department		Char(30) = '189',
		@PayrollWeek	Date = '12/23/2017',
		@Company		Varchar(5)

DECLARE	@tblCompany Table (
		Department		Char(3),
		Location		Varchar(25),
		Company			Varchar(5),
		GLAccount		Varchar(20))

INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('256', 'Memphis', 'IMC', '1-00-5030')
INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('191', 'Jacksonville', 'AIS', '0-00-5030')
INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('189', 'Norfolk', 'AIS', '0-00-5030')
INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('195', 'Savannah', 'AIS', '0-00-5030')
INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('121', 'Kearny', 'HMIS', '0-00-5030')
INSERT INTO @tblCompany (Department, Location, Company, GLAccount) VALUES ('190', 'Philadelphia', 'HMIS', '0-00-5030')
		
DECLARE	@BatchId		Varchar(25),
		@GLAccount		Varchar(20)

SELECT	@Company	= Company,
		@GLAccount	= GLAccount
FROM	@tblCompany 
WHERE	Department = @Department

SET @BatchId = (SELECT TOP 1 @Integration + RTRIM(Department) + '_' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + dbo.PADL(DAY(PayrollWeek), 2, '0') + RIGHT(dbo.PADL(YEAR(PayrollWeek), 4, '0'), 2) FROM HMIS_PayrollFiles WHERE Department = @Department AND PayrollWeek = @PayrollWeek)

DELETE	Integrations_AP
WHERE	Integration = @Integration
		AND BatchId = @BatchId
		AND Company = @Company

DELETE	ReceivedIntegrations
WHERE	Integration = @Integration
		AND BatchId = @BatchId
		AND Company = @Company

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
SELECT	Integration,
		Company,
		BatchId,
		VoucherNumber,
		VendorId,
		DocumentNumber,
		DocType,
		DocAmount,
		DocDate,
		PstgDate,
		PONumber,
		ChargeAmount,
		Ten99,
		PurchAmount,
		Description,
		Currency,
		Rate,
		ExchangeDate,
		RateExpress,
		CreateDist,
		CASE WHEN Debit <> 0 THEN 6 ELSE 2 END AS DisType,
		AccountNumber,
		Debit,
		Credit,
		Description,
		0
FROM	(
		SELECT	@Integration AS Integration,
				@Company AS Company,
				@BatchId AS BatchId,
				@Integration + InvoiceNum AS VoucherNumber,
				VendorId,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS DocumentNumber,
				1 AS DocType,
				SUM(Amount) AS DocAmount,
				MIN(PayrollWeek) AS DocDate,
				CAST(GETDATE() AS Date) AS PstgDate,
				Null AS PONumber,
				SUM(Amount) AS ChargeAmount,
				SUM(Amount) AS Ten99,
				SUM(Amount) AS PurchAmount,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS Description,
				'USD2' AS Currency,
				1001 AS Rate,
				'01/01/2007' AS ExchangeDate,
				0 AS RateExpress,
				0 AS CreateDist,
				@GLAccount AS AccountNumber,
				SUM(CASE WHEN Amount > 0 THEN Amount ELSE 0 END) AS Debit,
				0 AS Credit
		FROM	HMIS_PayrollFiles
		WHERE	Department = @Department
				AND PayrollWeek = @PayrollWeek
				AND Description NOT LIKE 'DED%'
		GROUP BY
				VendorId,
				Department,
				PayrollWeek,
				InvoiceNum
		UNION
		SELECT	@Integration AS Integration,
				@Company AS Company,
				@BatchId AS BatchId,
				@Integration + InvoiceNum AS VoucherNumber,
				VendorId,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS DocumentNumber,
				1 AS DocType,
				SUM(Amount) AS DocAmount,
				MIN(PayrollWeek) AS DocDate,
				CAST(GETDATE() AS Date) AS PstgDate,
				Null AS PONumber,
				SUM(Amount) AS ChargeAmount,
				SUM(Amount) AS Ten99,
				SUM(Amount) AS PurchAmount,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS Description,
				'USD2' AS Currency,
				1001 AS Rate,
				'01/01/2007' AS ExchangeDate,
				0 AS RateExpress,
				0 AS CreateDist,
				@GLAccount AS AccountNumber,
				0 AS Debit,
				SUM(CASE WHEN Amount < 0 THEN ABS(Amount) ELSE 0 END) AS Credit
		FROM	HMIS_PayrollFiles
		WHERE	Department = @Department
				AND PayrollWeek = @PayrollWeek
				AND Description NOT LIKE 'DED%'
		GROUP BY
				VendorId,
				Department,
				PayrollWeek,
				InvoiceNum
		UNION
		SELECT	@Integration AS Integration,
				@Company AS Company,
				@BatchId AS BatchId,
				@Integration + InvoiceNum AS VoucherNumber,
				VendorId,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS DocumentNumber,
				1 AS DocType,
				SUM(Amount) AS DocAmount,
				MIN(PayrollWeek) AS DocDate,
				CAST(GETDATE() AS Date) AS PstgDate,
				Null AS PONumber,
				SUM(Amount) AS ChargeAmount,
				SUM(Amount) AS Ten99,
				SUM(Amount) AS PurchAmount,
				'WE ' + dbo.PADL(MONTH(PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(PayrollWeek), 2, '0') + ' PAY' AS Description,
				'USD2' AS Currency,
				1001 AS Rate,
				'01/01/2007' AS ExchangeDate,
				0 AS RateExpress,
				0 AS CreateDist,
				'0-00-2050' AS AccountNumber,
				0 AS Debit,
				ABS(SUM(Amount)) AS Credit
		FROM	HMIS_PayrollFiles
		WHERE	Department = @Department
				AND PayrollWeek = @PayrollWeek
				AND Description NOT LIKE 'DED%'
		GROUP BY
				VendorId,
				Department,
				PayrollWeek,
				InvoiceNum
		) DATA
WHERE	Debit + Credit <> 0
ORDER BY
		VendorId,
		DocumentNumber

INSERT INTO ReceivedIntegrations(Integration, Company, BatchId) VALUES (@Integration, @Company, @BatchId)