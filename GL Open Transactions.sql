DECLARE @GLAccount	Varchar(15) = '0-88-1866',
		@CutoffDate	Date = '03/07/2020'

SELECT	Trx_Status,
		Trx_Date,
		Journal_Entry,
		Account_Number,
		Debit_Amount - Credit_Amount AS Amount,
		GPD.Reference,
		Pro,
		TRX_Source,
		CASE WHEN GPD.VendorId = '' THEN ISNULL(FSI.RecordCode, '') ELSE GPD.VendorId END AS VendorId,
		UPPER(CASE WHEN GPD.VendorId = '' THEN ISNULL(LEFT(RTRIM(VND.VENDNAME), 100), '') ELSE GPD.VendorName END) AS VendorName,
		Series,
		SeriesType,
		Period,
		Batch_Number
FROM	(
		SELECT	GL.Trx_Status,
				CAST(GL.TRXDATE AS Date) Trx_Date,
				GL.JRNENTRY Journal_Entry,
				RTRIM(GM.ACTNUMST) Account_Number,
				GL.DEBITAMT Debit_Amount,
				GL.CRDTAMNT Credit_Amount,
				RTRIM(GL.REFRENCE) Reference,
				GPCustom.dbo.FindProNumber(GL.REFRENCE) AS Pro,
				GL.ORTRXSRC TRX_Source,
				RTRIM(GL.ORMSTRID) VendorId,
				RTRIM(GL.ORMSTRNM) VendorName,
				--GL.ORDOCNUM Originating_Doc_Number,
				GL.ORGNTSRC Batch_Number,
				GL.SERIES,
				CASE GL.SERIES
					WHEN 1 THEN 'All'
					WHEN 2 THEN 'Financial'
					WHEN 3 THEN 'Sales'
					WHEN 4 THEN 'Purchasing'
					WHEN 5 THEN 'Inventory'
					WHEN 6 THEN 'Payroll – USA'
					WHEN 7 THEN 'Project'
					WHEN 10 THEN '3rd Party'
					ELSE 'Other'
				END SeriesType,
				CONVERT(Char(3), TRXDATE, 0) + '-' + RIGHT(YEAR(TRXDATE), 2) Period
		FROM	(
				SELECT	ACTINDX, TRXDATE, SOURCDOC, JRNENTRY, ORTRXSRC, REFRENCE,
						ORDOCNUM, ORMSTRID, ORMSTRNM, DEBITAMT, CRDTAMNT, CURNCYID,
						Trx_Status = 'Open', ORGNTSRC, SERIES, DSCRIPTN 
				FROM	GL20000
				WHERE	SOURCDOC NOT IN ('BBF','P/L')
						AND VOIDED = 0
						AND ACTINDX IN (SELECT ACTINDX FROM GL00105 WHERE ACTNUMST = @GLAccount)
						AND TRXDATE = @CutoffDate
				) GL
				INNER JOIN GL00105 GM ON GL.ACTINDX = GM.ACTINDX
				INNER JOIN GL00100 GA ON GL.ACTINDX = GA.ACTINDX
		) GPD
		LEFT JOIN IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FSI ON GPD.Pro = FSI.InvoiceNumber AND ABS(GPD.Debit_Amount + GPD.Credit_Amount) = FSI.ChargeAmount1 AND FSI.RecordType = 'VND' AND GPD.Pro <> '' AND GPD.VendorId = '' AND GPD.Series = 2
		LEFT JOIN PM00200 VND ON ISNULL(FSI.RecordCode, GPD.VendorId) = VND.VENDORID
ORDER BY Pro, Reference, Debit_Amount + Credit_Amount