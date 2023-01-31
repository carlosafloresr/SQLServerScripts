USE GPCustom 
GO

/*
EXECUTE USP_AR_Historical_Trial_Balance 'GIS', '12/03/2022', '46100', 0, 0, 1
EXECUTE USP_AR_Historical_Trial_Balance 'IMC', '03/17/2022', '24024', 0, 0, 0
EXECUTE USP_AR_Historical_Trial_Balance 'IMC', '03/17/2022', '24024', 1, 1, 1
*/
ALTER PROCEDURE dbo.USP_AR_Historical_Trial_Balance
		@Company				Varchar(5),
		@AsOfDate				Date = Null,
		@Customer				varchar(15) = Null,
		@Summary				Bit = 0,
		@SortByName				Bit = 0,
		@BasicData				Bit = 1
AS
SET NOCOUNT ON

IF @AsOfDate IS Null
	SET @AsOfDate = GETDATE()

DECLARE @Query					Varchar(MAX),
		@NatAccts				Bit = 0,
		@CustName				Varchar(100)

DECLARE	@tblCustomers			Table (
		CustomerId				Varchar(15), 
		CustomerName			Varchar(100), 
		NationalAccount			Varchar(15),
		PriceLevel				Varchar(30))

DECLARE	@tblAgedReport			Table (
		[APPLY_AMOUNT]			Numeric(12, 2) NOT NULL,
		[AGING_AMOUNT]			Numeric(12, 2) NOT NULL,
		[CUSTNMBR]				Char(15) NOT NULL,
		[CUSTNAME]				Char(65) NOT NULL,
		[BALNCTYP]				Smallint NOT NULL,
		[USERDEF1]				Char(21) NOT NULL,
		[CNTCPRSN]				Char(61) NOT NULL,
		[PHONE1]				Char(21) NOT NULL,
		[SLPRSNID]				Char(15) NOT NULL,
		[SALSTERR]				Char(15) NOT NULL,
		[PYMTRMID]				Char(21) NOT NULL,
		[CRLMTAMT]				Numeric(12, 2) NOT NULL,
		[CRLMTPER]				Smallint NOT NULL,
		[CRLMTPAM]				Numeric(12, 2) NOT NULL,
		[CRLMTTYP]				Smallint NOT NULL,
		[CUSTCLAS]				Char(15) NOT NULL,
		[SHRTNAME]				Char(15) NOT NULL,
		[ZIP]					Char(11) NOT NULL,
		[STATE]					Char(29) NOT NULL,
		[CUDSCRIPTN]			Char(31) NOT NULL,
		[AGNGDATE]				Date NOT NULL,
		[CHCUMNUM]				Char(15) NOT NULL,
		[DOCNUMBR]				Char(21) NOT NULL,
		[RMDTYPAL]				Smallint NOT NULL,
		[DSCRIPTN]				Char(31) NOT NULL,
		[DCURNCYID]				Char(15) NOT NULL,
		[ORTRXAMT]				Numeric(12, 2) NOT NULL,
		[CURTRXAM]				Numeric(12, 2) NOT NULL,
		[AGNGBUKT]				Smallint NOT NULL,
		[CASHAMNT]				Numeric(12, 2) NOT NULL,
		[COMDLRAM]				Numeric(12, 2) NOT NULL,
		[SLSAMNT]				Numeric(12, 2) NOT NULL,
		[COSTAMNT]				Numeric(12, 2) NOT NULL,
		[FRTAMNT]				Numeric(12, 2) NOT NULL,
		[MISCAMNT]				Numeric(12, 2) NOT NULL,
		[TAXAMNT]				Numeric(12, 2) NOT NULL,
		[DISAVAMT]				Numeric(12, 2) NOT NULL,
		[DDISTKNAM]				Numeric(12, 2) NOT NULL,
		[DWROFAMNT]				Numeric(12, 2) NOT NULL,
		[TRXDSCRN]				Char(31) NOT NULL,
		[DOCABREV]				Char(3) NOT NULL,
		[CHEKNMBR]				Char(21) NOT NULL,
		[DOCDATE]				Date NOT NULL,
		[DUEDATE]				Date NOT NULL,
		[GLPOSTDT]				Date NOT NULL,
		[DISCDATE]				Date NOT NULL,
		[POSTDATE]				Date NOT NULL,
		[DINVPDOF]				Date NOT NULL,
		[DCURRNIDX]				Smallint NOT NULL,
		[DXCHGRATE]				Numeric(19, 7) NOT NULL,
		[ORCASAMT]				Numeric(12, 2) NOT NULL,
		[ORSLSAMT]				Numeric(12, 2) NOT NULL,
		[ORCSTAMT]				Numeric(12, 2) NOT NULL,
		[ORDAVAMT]				Numeric(12, 2) NOT NULL,
		[ORFRTAMT]				Numeric(12, 2) NOT NULL,
		[ORMISCAMT]				Numeric(12, 2) NOT NULL,
		[ORTAXAMT]				Numeric(12, 2) NOT NULL,
		[ORCTRXAM]				Numeric(12, 2) NOT NULL,
		[ORORGTRX]				Numeric(12, 2) NOT NULL,
		[DORDISTKN]				Numeric(12, 2) NOT NULL,
		[DORWROFAM]				Numeric(12, 2) NOT NULL,
		[DDENXRATE]				Numeric(19, 7) NOT NULL,
		[DMCTRXSTT]				Smallint NOT NULL,
		[Aging_Period_Amount]	Numeric(12, 2) NOT NULL,
		[APFRDCNM]				Char(21) NOT NULL,
		[APFRDCTY]				Smallint NOT NULL,
		[FROMCURR]				Char(15) NOT NULL,
		[APTODCNM]				Char(21) NOT NULL,
		[APTODCTY]				Smallint NOT NULL,
		[APPTOAMT]				Numeric(12, 2) NOT NULL,
		[ACURNCYID]				Char(15) NOT NULL,
		[DATE1]					Date NOT NULL,
		[POSTED]				Tinyint NOT NULL,
		[ADISTKNAM]				Numeric(12, 2) NOT NULL,
		[AWROFAMNT]				Numeric(12, 2) NOT NULL,
		[PPSAMDED]				Numeric(12, 2) NOT NULL,
		[GSTDSAMT]				Numeric(12, 2) NOT NULL,
		[ACURRNIDX]				Smallint NOT NULL,
		[AXCHGRATE]				Numeric(19, 7) NOT NULL,
		[RLGANLOS]				Numeric(12, 2) NOT NULL,
		[ORAPTOAM]				Numeric(12, 2) NOT NULL,
		[AORDISTKN]				Numeric(12, 2) NOT NULL,
		[AORWROFAM]				Numeric(12, 2) NOT NULL,
		[ADENXRATE]				Numeric(19, 7) NOT NULL,
		[AMCTRXSTT]				Smallint NOT NULL)

DECLARE	@tblResult			Table (
		Customer_ID			Varchar(15) Null,
		Customer_Name		Varchar(200) Null,
		Customer			Varchar(150) Null,
		NationalId			Varchar(15),
		NationalAccount		Varchar(150),
		Customer_Terms		varchar(30) Null,
		Customer_Class		Varchar(10) Null,
		Price_Level			Varchar(20) Null,
		Document_Type		Varchar(15) Null,
		Document_Number		Varchar(30) Null,
		Document_Date		Date Null,
		Due_Date			Date Null,
		Last_Payment_Date	Date Null,
		Document_Amount		Numeric(18,3),
		Unapplied_Amount	Numeric(18,3),
		[Current]			Numeric(18,3),
		[0_to_30_Days]		Numeric(18,3),
		[31_to_60_Days]		Numeric(18,3),
		[61_to_90_Days]		Numeric(18,3),
		[91_to_180_Days]	Numeric(18,3),
		[180_and_Over]		Numeric(18,3),
		Balance				Numeric(18,3),
		SummaryRow			Smallint,
		DataCounter			Int Null)

SET @Query = N'SELECT RTRIM(CUSTNMBR), RTRIM(CUSTNAME), RTRIM(CPRCSTNM), RTRIM(PRCLEVEL) FROM ' + @Company + '.dbo.RM00101'

INSERT INTO @tblCustomers
EXECUTE(@Query)

SET @Query = N'EXECUTE ' + @Company + '.dbo.SeermHATBSRSWrapper ''' + CONVERT(Char(10), @AsOfDate, 101)  + ''','
 
IF @Customer IS Null
BEGIN
	SET @Query = @Query + '''0'',''zzz'','
END
ELSE
BEGIN
	SET @Query = @Query + '''' + RTRIM(@Customer) + ''',''' + RTRIM(@Customer) + ''','
END

SET @Query = @Query + ''''','''',' -- I_cStartCustomerName, I_cEndCustomerName
SET @Query = @Query + ''''','''',' -- I_cStartClassID, I_cEndClassID
SET @Query = @Query + ''''','''',' -- I_cStartSalesPersonID, I_cEndSalesPersonID
SET @Query = @Query + ''''','''',' -- I_cStartSalesTerritory, I_cEndSalesTerritory
SET @Query = @Query + ''''','''',' -- I_cStartShortName, I_cEndShortName
SET @Query = @Query + ''''','''',' -- I_cStartState, I_cEndState
SET @Query = @Query + ''''','''',' -- I_cStartZipCode, I_cEndZipCode
SET @Query = @Query + ''''','''',' -- I_cStartPhoneNumber, I_cEndPhoneNumber
SET @Query = @Query + ''''','''',' -- I_cStartUserDefined, I_cEndUserDefined
SET @Query = @Query + '0,' -- I_tUsingDocumentDate
SET @Query = @Query + '''01/01/1900'',''' + CONVERT(Char(10), @AsOfDate, 101)  + ''',' -- I_dStartDate, I_dEndDate
SET @Query = @Query + '0,' -- I_sIncludeBalanceTypes
SET @Query = @Query + '1,' -- I_tExcludeNoActivity
SET @Query = @Query + '1,' -- I_tExcludeMultiCurrency
SET @Query = @Query + '1,' -- I_tExcludeZeroBalanceCustomer
SET @Query = @Query + '1,' -- I_tExcludeFullyPaidTrxs
SET @Query = @Query + '0,' -- I_tExcludeCreditBalance
SET @Query = @Query + '1,' -- I_tExcludeUnpostedAppldCrDocs
SET @Query = @Query + IIF(@NatAccts = 1, '1', '0') -- I_tConsolidateNAActivity

INSERT INTO @tblAgedReport
EXECUTE(@Query)

IF @BasicData = 0
BEGIN
INSERT INTO @tblResult
SELECT	RTRIM(DATA.CUSTNMBR) AS Customer_ID,
		RTRIM(DATA.CUSTNAME) AS Customer_Name,
		IIF(@SortByName = 1, RTRIM(DATA.CUSTNAME) + ' [' + RTRIM(DATA.CUSTNMBR) + ']', RTRIM(DATA.CUSTNMBR) + ' - ' + RTRIM(DATA.CUSTNAME)) AS Customer,
		CUST.NationalAccount,
		NATA.CustomerName,
		DATA.PYMTRMID,
		DATA.CUSTCLAS,
		CUST.PriceLevel,
		CASE DATA.RMDTYPAL
			  WHEN 1 THEN 'Invoice'
			  WHEN 3 THEN 'Debit Memo'
			  WHEN 4 THEN 'Finance Charge'
			  WHEN 5 THEN 'Service Repair'
			  WHEN 6 THEN 'Warranty'
			  WHEN 7 THEN 'Credit Memo'
			  WHEN 8 THEN 'Return'
			  WHEN 9 THEN 'Payment'
			  ELSE 'Other'
			  END Document_Type,
		DATA.DOCNUMBR,
		DATA.DOCDATE,
		DATA.DUEDATE,
		Null AS Last_Payment_Date,
		DATA.ORTRXAMT,
		DATA.CURTRXAM AS Unapplied_Amount,
		ISNULL(CASE WHEN DATA.AGNGBUKT = 1 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [Current],
		ISNULL(CASE WHEN DATA.AGNGBUKT = 1 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [0-30],
		ISNULL(CASE WHEN DATA.AGNGBUKT = 2 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [31-60],
		ISNULL(CASE WHEN DATA.AGNGBUKT = 3 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [61-90],
		ISNULL(CASE WHEN DATA.AGNGBUKT = 4 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [91-180],
		ISNULL(CASE WHEN DATA.AGNGBUKT = 5 THEN DATA.aging_Amount + DATA.apply_amount END,0) AS [181-More],
		DATA.aging_Amount + DATA.apply_amount AS Balance,
		0 AS SummaryRow,
		DataCounter = (SELECT COUNT(TMPD.CUSTNMBR) FROM @tblAgedReport TMPD WHERE TMPD.CUSTNMBR = DATA.CUSTNMBR)
FROM	@tblAgedReport DATA
		LEFT JOIN @tblCustomers CUST ON DATA.CUSTNMBR = CUST.CustomerId
		LEFT JOIN @tblCustomers NATA ON CUST.NationalAccount = NATA.CustomerId

INSERT INTO @tblResult
SELECT	Customer_ID,
		Customer_Name,
		Customer,
		NationalId,
		NationalAccount,
		Customer_Terms,
		Customer_Class,
		'' AS Price_Level,
		'' AS Document_Type,
		'' AS Document_Number,
		MAX(Document_Date) AS Document_Date,
		MAX(Due_Date) AS Due_Date,
		Null AS Last_Payment_Date,
		0 AS Document_Amount,
		0 AS Unapplied_Amount,
		SUM([Current]) AS [Current],
		0 AS [0_to_30_Days],
		SUM([31_to_60_Days]) AS [31_to_60_Days],
		SUM([61_to_90_Days]) AS [61_to_90_Days],
		SUM([91_to_180_Days]) AS [91_to_180_Days],
		SUM([180_and_Over]) AS [180_and_Over],
		SUM(Balance) AS Balance,
		1 AS SummaryRow,
		0 AS DataCounter
FROM	@tblResult
GROUP BY
		Customer_ID,
		Customer_Name,
		Customer,
		NationalId,
		NationalAccount,
		Customer_Terms,
		Customer_Class

IF @Summary = 1
	DELETE @tblResult WHERE SummaryRow = 0

IF (SELECT COUNT(*) FROM @tblResult) = 0
BEGIN
	INSERT INTO @tblResult
			(Customer_ID,
			Customer_Name,
			[Current],
			Balance,
			SummaryRow)
	VALUES
			(IIF(@Customer IS Null, '', @Customer),
			ISNULL(@CustName,''),
			0,
			0,
			1)
END
ELSE
BEGIN
	INSERT INTO @tblResult
	SELECT	'ZZZZZZ' AS Customer_ID,
			'ZZZZZZ' AS Customer_Name,
			'S U M M A R Y' AS Customer,
			'' AS NationalId,
			'' AS NationalAccount,
			Null AS Customer_Terms,
			Null AS Customer_Class,
			Null AS Price_Level,
			Null AS Document_Type,
			Null AS Document_Number,
			Null AS Document_Date,
			Null AS Due_Date,
			Null AS Last_Payment_Date,
			0 AS Document_Amount,
			0 AS Unapplied_Amount,
			SUM([Current]) AS [Current],
			0 AS [0_to_30_Days],
			SUM([31_to_60_Days]) AS [31_to_60_Days],
			SUM([61_to_90_Days]) AS [61_to_90_Days],
			SUM([91_to_180_Days]) AS [91_to_180_Days],
			SUM([180_and_Over]) AS [180_and_Over],
			SUM(Balance) AS Balance,
			-1 AS SummaryRow,
			0 AS DataCounter
	FROM	@tblResult
	WHERE	SummaryRow = 1
END

SELECT	Customer_ID AS Customer,
		Customer AS CustomerName,
		Document_Number AS DocNumber,
		Document_Date AS DocDate,
		Due_Date AS DueDate,
		Document_Amount AS DocAmount,
		[Current],
		[31_to_60_Days] AS Days31_60,
		[61_to_90_Days] AS Days61_90,
		[91_to_180_Days] AS Days91_180,
		[180_and_Over] AS Days180More,
		Balance,
		CompanyName,
		SummaryRow AS IsSummary,
		DataCounter,
		Null AS PortDischargeDate,
		(SELECT COUNT(*) FROM (SELECT DISTINCT Customer_ID FROM @tblResult) DATA) AS CountCustomers,
		Customer_Name
FROM	@tblResult DATA
		INNER JOIN GPCustom.dbo.Companies CPY ON CPY.CompanyId = @Company
ORDER BY
		Customer_Name,
		IsSummary DESC,
		Due_Date,
		Document_Date,
		Document_Number
END
ELSE
BEGIN
	IF @Summary = 1
	BEGIN
		SELECT	RTRIM(CUSTNMBR) AS CustomerId,
				IIF(LEN(RTRIM(CUSTNAME)) > 38, LEFT(RTRIM(CUSTNAME), 38) + ' [' + RTRIM(CUSTNMBR) + ']', RTRIM(CUSTNAME)) AS CustomerName,
				ISNULL(SUM(CASE WHEN AGNGBUKT = 1 THEN aging_Amount + apply_amount END),0) AS [Current],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 2 THEN aging_Amount + apply_amount END),0) AS [31-60],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 3 THEN aging_Amount + apply_amount END),0) AS [61-90],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 4 THEN aging_Amount + apply_amount END),0) AS [91-180],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 5 THEN aging_Amount + apply_amount END),0) AS [181-More],
				SUM(aging_Amount + apply_amount) AS Balance
		FROM	@tblAgedReport
		GROUP BY RTRIM(CUSTNMBR), RTRIM(CUSTNAME)
		ORDER BY IIF(@SortByName = 0, RTRIM(CUSTNMBR), RTRIM(CUSTNAME))
	END
	ELSE
	BEGIN
		SELECT	RTRIM(CUSTNMBR) AS CustomerId,
				RTRIM(CUSTNAME) AS CustomerName,	
				DOCDATE AS TrxDate,
				RTRIM(DOCNUMBR) AS Document,
				RMDTYPAL AS DocType,
				ISNULL(SUM(CASE WHEN AGNGBUKT = 1 THEN aging_Amount + apply_amount END),0) AS [Current],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 2 THEN aging_Amount + apply_amount END),0) AS [31-60],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 3 THEN aging_Amount + apply_amount END),0) AS [61-90],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 4 THEN aging_Amount + apply_amount END),0) AS [91-180],
				ISNULL(SUM(CASE WHEN AGNGBUKT = 5 THEN aging_Amount + apply_amount END),0) AS [181-More],
				SUM(aging_Amount + apply_amount) AS Balance
		FROM	@tblAgedReport
		GROUP BY RTRIM(CUSTNMBR), RTRIM(CUSTNAME), DOCDATE, RTRIM(DOCNUMBR), RMDTYPAL
		ORDER BY IIF(@SortByName = 0, RTRIM(CUSTNMBR), RTRIM(CUSTNAME)), 3, 4
	END
END