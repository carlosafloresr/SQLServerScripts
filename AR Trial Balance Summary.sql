SELECT	Agent,
		Customer_ID, 
		Customer_Name,
		Customer_Terms, 
		Customer_Class,
		CAST([Current] AS Numeric(10,2)) AS [Current],
		CAST([0_to_30_Days] AS Numeric(10,2)) AS [0_to_30_Days],
		CAST([31_to_60_Days] AS Numeric(10,2)) AS [31_to_60_Days],
		CAST([61_to_90_Days] AS Numeric(10,2)) AS [61_to_90_Days],
		CAST([91_AND_Over] AS Numeric(10,2)) AS [91_AND_Over],
		CAST(CurrentBalance AS Numeric(10,2)) AS CurrentBalance,
		CAST(Last_Payment_Date AS Date) AS Last_Payment_Date,
		CAST(Last_Payment_Amount AS Numeric(10,2)) AS Last_Payment_Amount
FROM	(
		SELECT	RTRIM(CM.CUSTNMBR) Customer_ID, 
				RTRIM(CM.CUSTNAME) Customer_Name,
				CM.PYMTRMID Customer_Terms, 
				RTRIM(CM.CUSTCLAS) Customer_Class,
				RM.Agent,
				SUM(CASE
					WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) <= 0 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
					WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) <= 0 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1
					ELSE 0
					END) [Current],
				SUM(CASE 
					WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 1 AND 30 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
					WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 1 AND 30 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
					ELSE 0
					END) [0_to_30_Days],
				SUM(CASE
					WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 31 AND 60 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
					WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 31 AND 60 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
					ELSE 0
					END) [31_to_60_Days],
				SUM(CASE
					WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) between 61 AND 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
					WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) between 61 AND 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1
					ELSE 0
					END) [61_to_90_Days],
				SUM(CASE
					WHEN DATEDIFF(d, RM.DUEDATE, GETDATE()) > 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM
					WHEN DATEDIFF(d, RM.DOCDATE, GETDATE()) > 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1
					ELSE 0
					END) [91_AND_Over],
				SUM(CASE WHEN RM.RMDTYPAL < 7 THEN RM.CURTRXAM ELSE RM.CURTRXAM * -1 END) CurrentBalance,
				CS.LASTPYDT Last_Payment_Date,
				CS.LPYMTAMT Last_Payment_Amount
		FROM	(
				SELECT	*,
						CASE WHEN GPCustom.dbo.AT('_', DOCNUMBR, 1) > 0 THEN SUBSTRING(DOCNUMBR, GPCustom.dbo.AT('_', DOCNUMBR, 1) + 1, 2) ELSE SLSTERCD END AS Agent
				FROM	RM20101
				) RM
				INNER JOIN RM00101 CM ON RM.CUSTNMBR = CM.CUSTNMBR
				INNER JOIN RM00103 CS ON RM.CUSTNMBR = CS.CUSTNMBR
		WHERE	RM.VOIDSTTS = 0 
				AND RM.CURTRXAM <> 0
		GROUP BY 
				CM.CUSTNMBR, 
				CM.CUSTNAME, 
				CM.PYMTRMID, 
				CM.CUSTCLAS, 
				CS.LASTPYDT,
				CS.LPYMTAMT,
				RM.Agent
		) DATA
ORDER BY
		Customer_ID,
		Agent