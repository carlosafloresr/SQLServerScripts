SELECT	Agent,
		Customer_ID,
		Customer_Name,
		Customer_Terms,
		Customer_Class,
		Document_Type,
		Document_Number,
		Customer_Reference = (SELECT TOP 1 FSI.BillToRef FROM IntegrationsDB.Integrations.dbo.View_Integration_FSI FSI WHERE FSI.Company = DB_NAME() AND FSI.VoucherNumber = DATA.Document_Number),
		Document_Date,
		Due_Date,
		Last_Payment_Date,
		CAST(Document_Amount AS Numeric(10,2)) Document_Amount,
		CAST(Unapplied_Amount AS Numeric(10,2)) Unapplied_Amount,
		CAST([Current] AS Numeric(10,2)) [Current],
		CAST([0_to_30_Days] AS Numeric(10,2)) [0_to_30_Days],
		CAST([31_to_60_Days] AS Numeric(10,2)) [31_to_60_Days],
		CAST([61_to_90_Days] AS Numeric(10,2)) [61_to_90_Days],
		CAST([91_and_Over] AS Numeric(10,2)) [91_and_Over]
FROM	(
		SELECT	RTRIM(CM.CUSTNMBR) Customer_ID,
				RTRIM(CM.CUSTNAME) Customer_Name,
				RM.Agent,
				CM.PYMTRMID Customer_Terms,
				RTRIM(CM.CUSTCLAS) Customer_Class,
				CASE RM.RMDTYPAL
					WHEN 1 THEN 'Sale / Invoice'
					WHEN 3 THEN 'Debit Memo'
					WHEN 4 THEN 'Finance Charge'
					WHEN 5 THEN 'Service Repair'
					WHEN 6 THEN 'Warranty'
					WHEN 7 THEN 'Credit Memo'
					WHEN 8 THEN 'Return'
					WHEN 9 THEN 'Payment'
					ELSE 'Other'
					END Document_Type,
				RTRIM(RM.DOCNUMBR) Document_Number,
				CAST(RM.DOCDATE AS Date) Document_Date,
				CAST(RM.DUEDATE AS Date) Due_Date,
				CAST(S.LASTPYDT AS Date) Last_Payment_Date,
			CASE
				WHEN RM.RMDTYPAL < 7 THEN RM.ORTRXAMT
				ELSE RM.ORTRXAMT * -1
				END Document_Amount,
			CASE
				WHEN RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				ELSE RM.CURTRXAM * -1
				END Unapplied_Amount,
			CASE
				WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) <= 0 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) <= 0 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1
				ELSE 0
				END [Current],
			CASE 
				WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 1 AND 30 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 1 AND 30 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
				ELSE 0
				END [0_to_30_Days],
			CASE
				WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 31 AND 60 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 31 AND 60 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
				ELSE 0
				END [31_to_60_Days],
			CASE
				WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 61 AND 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 61 AND 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
				ELSE 0
				END [61_to_90_Days],
			CASE
				WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) > 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
				WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) > 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1
				ELSE 0
				END [91_and_Over]
		FROM	(
				SELECT	*,
						CASE WHEN GPCustom.dbo.AT('_', DOCNUMBR, 1) > 0 THEN SUBSTRING(DOCNUMBR, GPCustom.dbo.AT('_', DOCNUMBR, 1) + 1, 2) ELSE SLSTERCD END AS Agent
				FROM	RM20101
				) RM
				INNER JOIN RM00101 CM ON RM.CUSTNMBR = CM.CUSTNMBR
				LEFT OUTER JOIN RM00103 S ON RM.CUSTNMBR = S.CUSTNMBR
		WHERE	RM.VOIDSTTS = 0 
				AND RM.CURTRXAM <> 0
				--AND CM.CUSTNMBR = '10076'
		) DATA
ORDER BY
		Customer_ID,
		Agent