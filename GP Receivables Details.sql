DECLARE @DateIni	Date = '06/28/2020',
		@DateEnd	Date = '05/10/2022'

DECLARE @tblCustData Table (
		CUSTNMBR	char(15),
        DOCNUMBR	char(21),
        CHEKNMBR	char(21),
		BACHNUMB	char(15),
		RMDTYPAL	smallint,
		CSHRCTYP	smallint,
		DOCDATE		date,
		GLPOSTDT	date,
        ORTRXAMT	numeric(12,2),
        CURTRXAM	numeric(12,2),
		CSPORNBR	char(21),
        DINVPDOF	date,
		VOIDSTTS	smallint)

INSERT INTO @tblCustData
SELECT	CUSTNMBR, DOCNUMBR, CHEKNMBR, BACHNUMB, RMDTYPAL, CSHRCTYP, DOCDATE, GLPOSTDT, ORTRXAMT, CURTRXAM, CSPORNBR, DINVPDOF, VOIDSTTS
FROM	RM20101
WHERE	GLPOSTDT BETWEEN @DateIni AND @DateEnd
		AND VOIDSTTS = 0
UNION
SELECT	CUSTNMBR, DOCNUMBR, CHEKNMBR, BACHNUMB, RMDTYPAL, CSHRCTYP, DOCDATE, GLPOSTDT, ORTRXAMT, CURTRXAM, CSPORNBR, DINVPDOF, VOIDSTTS
FROM	RM30101
WHERE	GLPOSTDT BETWEEN @DateIni AND @DateEnd
		AND VOIDSTTS = 0



SELECT	T.CUSTNMBR Customer_ID,
		CM.CUSTNAME Customer_Name,
		CM.SHRTNAME Short_Name,
		T.DOCDATE Document_Date,
		T.GLPOSTDT GL_Posting_Date,
		CASE T.RMDTYPAL
				  WHEN 7 THEN 'Credit Memo'
				  WHEN 8 THEN 'Return'
				  WHEN 9 THEN 'Payment'
				  END AS RM_Doc_Type,
		T.BACHNUMB Payment_Batch,
		CASE T.RMDTYPAL
			WHEN 7 THEN 'Credit Memo'
			WHEN 8 THEN 'Return'
			WHEN 9 THEN
			CASE T.CSHRCTYP
				WHEN 0 THEN 'Payment - Check ' + CASE T.CHEKNMBR WHEN '' THEN '' ELSE '#' + T.CHEKNMBR END
				WHEN 1 THEN 'Payment - Cash'
				WHEN 2 THEN 'Payment - Credit Card'
				END
			END AS Document_Type_and_Number,
		T.DOCNUMBR Document_Number,
		T.ORTRXAMT Original_Trx_Amount,
		T.CURTRXAM Current_Trx_Amount,
		T.AmountApplied Total_Applied_Amount,
		A.APPTOAMT Amount_Applied,
		A.APTODCTY Applied_to_Doc_Type,
		A.debitType Applied_to_Doc_Type_Name,
		A.APTODCNM  Applied_to_Doc_Number,
		A.APTODCDT Applied_to_Document_Date,
		A.ApplyToGLPostDate Applied_to_GL_Posting_Date,
		A.DISTKNAM Discount,
		A.WROFAMNT Writeoff,
		A.DATE1 Apply_Document_Date,
		A.GLPOSTDT Apply_GL_Posting_Date,
		D.ORTRXAMT Applied_To_Doc_Total,
		D.DINVPDOF Applied_To_Date_Paid_Off,
		D.CURTRXAM Applied_To_Doc_Unapplied_Amount,
		D.CSPORNBR Customer_PO_Number
FROM	(
		SELECT	CUSTNMBR, DOCDATE, GLPOSTDT, RMDTYPAL,
				DOCNUMBR, ORTRXAMT, CURTRXAM, BACHNUMB, 
				CHEKNMBR, CSHRCTYP, ORTRXAMT - CURTRXAM AS AmountApplied 
		FROM	@tblCustData
		WHERE	RMDTYPAL > 6
		) T 
		INNER JOIN RM00101 CM ON T.CUSTNMBR = CM.CUSTNMBR 
		INNER JOIN (
					SELECT	tO1.CUSTNMBR, APTODCTY, APTODCNM,
							APFRDCTY,APFRDCNM,
							CASE APTODCTY
							  WHEN 1 THEN 'Sale / Invoice'
							  WHEN 2 THEN 'Scheduled Payment'
							  WHEN 3 THEN 'Debit Memo'
							  WHEN 4 THEN 'Finance Charge'
							  WHEN 5 THEN 'Service Repair'
							  WHEN 6 THEN 'Warranty'
							  END as debitType,
							APPTOAMT, ApplyToGLPostDate, APTODCDT, tO2.DISTKNAM,
							tO2.WROFAMNT, tO2.DATE1, tO2.GLPOSTDT 
					FROM	RM20201 tO2 
							INNER JOIN RM20101 tO1 ON tO2.APTODCTY = tO1.RMDTYPAL AND tO2.APTODCNM = tO1.DOCNUMBR 
					UNION
					SELECT	tH1.CUSTNMBR, APTODCTY, APTODCNM,
							APFRDCTY, APFRDCNM,
							CASE APTODCTY
							  WHEN 1 THEN 'Sale / Invoice'
							  WHEN 2 THEN 'Scheduled Payment'
							  WHEN 3 THEN 'Debit Memo'
							  WHEN 4 THEN 'Finance Charge'
							  WHEN 5 THEN 'Service Repair'
							  WHEN 6 THEN 'Warranty'
							  END AS debitType,
							APPTOAMT, ApplyToGLPostDate, APTODCDT, tH2.DISTKNAM,
							tH2.WROFAMNT, tH2.DATE1, tH2.GLPOSTDT
					FROM	RM30201 tH2 
							INNER JOIN RM30101 tH1 ON tH2.APTODCTY = tH1.RMDTYPAL AND tH2.APTODCNM = tH1.DOCNUMBR
					) A ON A.APFRDCTY = T.RMDTYPAL AND A.APFRDCNM = T.DOCNUMBR
		INNER JOIN @tblCustData D ON A.APTODCTY = D.RMDTYPAL AND A.APTODCNM = D.DOCNUMBR
