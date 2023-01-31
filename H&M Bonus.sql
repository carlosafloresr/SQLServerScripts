DECLARE	@PayrollWeek	Date = '12/23/2017',
		@BatchId		Varchar(25)

DECLARE	@tblCompany Table (
		Department		Char(3),
		Location		Varchar(25),
		Company			Varchar(5))

INSERT INTO @tblCompany (Department, Location, Company) VALUES ('256', 'Memphis','IMC')
INSERT INTO @tblCompany (Department, Location, Company) VALUES ('191', 'Jacksonville','AIS')
INSERT INTO @tblCompany (Department, Location, Company) VALUES ('189', 'Norfolk','AIS')
INSERT INTO @tblCompany (Department, Location, Company) VALUES ('195', 'Savannah','AIS')
INSERT INTO @tblCompany (Department, Location, Company) VALUES ('121', 'Kearny','HMIS')
INSERT INTO @tblCompany (Department, Location, Company) VALUES ('190', 'Philadelphia','HMIS')

DECLARE	@tblBonus Table (
		VendorId		Varchar(12),
		Amount			Numeric(10,2),
		GLAccount		Varchar(20),
		Description		Varchar(40),
		Location		Varchar(20))

SET @BatchId = 'BONUS-' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + dbo.PADL(DAY(@PayrollWeek), 2, '0') + dbo.PADL(YEAR(@PayrollWeek), 4, '0')

DELETE	Integrations_AP
WHERE	Integration = 'BONUS'
		AND BatchId = @BatchId

DELETE	ReceivedIntegrations
WHERE	Integration = 'BONUS'
		AND BatchId = @BatchId

INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61974',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61864',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62020',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61044',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61750',500,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('53341',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('51703',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61884',300,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61953',300,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61892',300,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61597',500,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61793',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62017',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61963',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62037',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61631',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60276',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61956',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60220',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60460',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62088',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61849',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61891',300,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61811',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61582',500,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60312',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61924',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61413',500,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62044',300,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61981',300,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61357',500,'0-00-2050','Longevity Bonus','NORFOLK')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61531',500,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61868',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60301',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60081',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('52230',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61119',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60167',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61816',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60410',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60079',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61753',500,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62124',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62001',300,'0-00-2050','Longevity Bonus','NORFOLK')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60309',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61882',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('80178',300,'0-00-2050','Longevity Bonus','NORFOLK')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60797',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61576',500,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60398',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61535',500,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60298',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61867',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61842',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61245',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61069',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61885',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61322',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61718',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61984',300,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61980',300,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61915',300,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61773',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62152',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62072',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62059',300,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61739',300,'0-00-2050','Longevity Bonus','Memphis')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60538',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61378',500,'0-00-2050','Longevity Bonus','Savannah')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61634',500,'0-00-2050','Longevity Bonus','Kearny')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('62043',300,'0-00-2050','Longevity Bonus','NORFOLK')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('60610',500,'0-00-2050','Longevity Bonus','Philadelphia')
INSERT INTO @tblBonus (VendorId, Amount, GLAccount, Description, Location) VALUES ('61815',500,'0-00-2050','Longevity Bonus','NORFOLK')

INSERT INTO @tblBonus
SELECT	VendorId, 
		Amount * -1, 
		CASE WHEN Location = 'Philadelphia' THEN '1-48-6143'
		     WHEN Location = 'NORFOLK' THEN '1-27-6143'
			 WHEN Location = 'Kearny' THEN '1-54-6143'
			 WHEN Location = 'Savannah' THEN '1-05-6332'
			 ELSE '1-09-6332'
		END AS GLAccount, 
		Description, 
		Location
FROM	@tblBonus

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
SELECT	'BONUS' AS Integration,
		CPY.Company,
		@BatchId AS BatchId,
		'BONUS-' + RTRIM(VendorId) + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + dbo.PADL(DAY(@PayrollWeek), 2, '0') + RIGHT(dbo.PADL(YEAR(@PayrollWeek), 4, '0'), 2) AS VoucherNumber,
		VendorId,
		'Longevity Bonus' AS DocumentNumber,
		1 AS DocType,
		ABS(Amount) AS DocAmount,
		@PayrollWeek AS DocDate,
		CAST(GETDATE() AS Date) AS PstgDate,
		Null AS PONumber,
		ABS(Amount) AS ChargeAmount,
		0 AS Ten99,
		ABS(Amount) AS PurchAmount,
		'Bonus ' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(@PayrollWeek), 2, '0') AS Description,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		CASE WHEN Amount > 0 THEN 2 ELSE 6 END AS DisType,
		GLAccount AS AccountNumber,
		CASE WHEN Amount < 0 THEN ABS(Amount) ELSE 0 END AS Debit,
		CASE WHEN Amount > 0 THEN ABS(Amount) ELSE 0 END AS Credit,
		'Bonus ' + dbo.PADL(MONTH(@PayrollWeek), 2, '0') + '/' + dbo.PADL(DAY(@PayrollWeek), 2, '0') AS Description,
		0 AS RecordId
FROM	@tblBonus BON
		INNER JOIN @tblCompany CPY ON BON.Location = CPY.Location
ORDER BY VendorId

INSERT INTO ReceivedIntegrations (Integration, Company, BatchId)
SELECT	DISTINCT 'BONUS',
		Company,
		@BatchId
FROM	@tblBonus BON
		INNER JOIN @tblCompany CPY ON BON.Location = CPY.Location