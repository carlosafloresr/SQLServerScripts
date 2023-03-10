/* =============================================================
	Author:			Jeff Crumbley
	Create date:	2010-12-15
	Description:	
	Revised:		Carlos A. Flores
	Revision date:	2017-11-15
	Description:	See below.
	EXEC Acct_PendLoad_Test
	EXEC Acct_PendLoad_Test @critCompany = '7', @InvoiceNum = 'BLAI0129562', @critStatus = '-100N'
	EXEC Acct_PendLoad_Test @critCompany = 7, @critStatus = '4C', @InvoiceNum = 'CHS9110129408X'
	EXEC Acct_PendLoad_Test @critCompany = '2', @critStatus = '-100U'
	EXEC Acct_PendLoad_Test @critCompany = '1', @InvoiceNum = 'PDUSR0008622'
	EXEC Acct_PendLoad_Test @critCompany = '1', @InvoiceNum = 'CHS9101286106X', @critContainer = 'MEDU866282'
   ============================================================= */
ALTER PROCEDURE [dbo].[Acct_PendLoad_Test]
		@InvoiceNum		varchar(20) = null, 
		@critCompany	int = null, 
		@critContainer	varchar(25) = null, 
		@critPro		varchar(15) = null, 
		@critAPInv		varchar(20) = null, 
		@critARInv		varchar(50) = null, 
		@critDiv		int = null, 
		@critVendor		varchar(200) = null, 
		@critBillTo		varchar(250) = null, 
		@critDate		varchar(2) = null, 
		@critFROM		varchar(10) = null, 
		@critTo			varchar(10) = null, 
		@critStatus		varchar(MAX) = null
AS
BEGIN
	DECLARE	@tblInvoiceIds	Table (
			CompanyID		Smallint, 
			InvoiceNum		Varchar(30), 
			LineItemNo		Smallint,
			InvoiceModId	Int)

	DECLARE	@tblInvoices	Table (
			InvoiceNum		Varchar(30))

	INSERT INTO @tblInvoiceIds
	SELECT	CompanyID, 
			InvoiceNum, 
			LineItemNo,
			MAX(InvoiceModId) AS [InvoiceModId]
	FROM	Accounting.dbo.InvoiceMod
	GROUP BY 
			CompanyID, 
			InvoiceNum, 
			LineItemNo

	INSERT INTO @tblInvoices
	SELECT	DISTINCT InvoiceNum 
	FROM	(
			SELECT	A.InvoiceNum AS [InvoiceNum]
			FROM	InvoiceDetail A
					LEFT OUTER JOIN InvoiceMaster B ON A.CompanyID = B.CompanyID AND A.InvoiceNum = B.InvoiceNum
					LEFT OUTER JOIN (
									SELECT	A.* 
									FROM	Accounting.dbo.InvoiceMod A
											INNER JOIN @tblInvoiceIds C ON A.CompanyID = C.CompanyID AND A.InvoiceNum = C.InvoiceNum AND A.LineItemNo = C.LineItemNo
									) C ON A.CompanyID = C.CompanyID AND A.InvoiceNum = C.InvoiceNum AND A.LineItemNo = C.LineItemNo
					LEFT OUTER JOIN Drivers.dbo.Companies D ON (A.CompanyID = D.ID)
					LEFT OUTER JOIN	Customers F ON A.CompanyID = F.Company AND A.BillToCustomer = F.CUSTNMBR
					LEFT OUTER JOIN	Customers E ON C.CompanyID = E.Company AND C.BillToCustomer = E.CUSTNMBR
			WHERE	A.[Status] NOT IN (2,-130)
					AND (@critContainer IS NULL OR ((C.EquipmentID LIKE @critContainer) OR (A.EquipmentID LIKE @critContainer)))
					AND (@critPro IS NULL OR ((C.ProNum LIKE @critPro) OR (A.ProNum LIKE @critPro)))
					AND (@critDiv IS NULL OR (ISNULL(C.DivisionNum, A.DivisionNum) = @critDiv) )
					AND (@critBillTo IS NULL OR ((C.BillToCustomer LIKE ('%'+ @critBillTo)) OR (A.BillToCustomer LIKE ('%'+ @critBillTo))))
					AND (@critVendor IS NULL OR (B.VendorID LIKE @critVendor))
					AND (@critARInv IS NULL OR (A.CustInvNum LIKE @critARInv))
					AND (@critDate IS NULL OR 
						(@critDate IS NOT NULL AND (@critFROM IS NULL OR @critTo IS NULL) OR
						((@critDate = 'AP' AND B.InvoiceDate Between @critFROM AND @critTo) OR 
						(@critDate = 'AR' AND A.CustInvDate Between @critFROM AND @critTo))))
					AND (@critStatus IS NULL OR ((RTRIM(CAST( A.[Status] AS varchar(5))) + RTRIM(CASE WHEN C.InvoiceModId IS NULL THEN A.LineItemStatus ELSE C.[Status] END)) IN (SELECT * FROM dbo.F_TBL_VALS_FROM_STRING(@critStatus))))
		) DATA

	SELECT	*
			,CASE WHEN (@InvoiceNum = NULL OR Q.InvoiceNum = @InvoiceNum) AND Q.RowType = 1 THEN 1 ELSE 0 END AS [Sign]
	FROM	(
			SELECT '1' AS [RowType]
				, D.CompanyID 
				, NULL AS [InvoiceDate]
				, D.InvoiceNum
				, NULL AS [LineItemNo]
				, NULL AS [Div]
				, NULL AS [Pro]
				, NULL AS [Container]
				, NULL AS [BillTo]
				, NULL AS [Consignee]
				, NULL AS [OutGate]
				, NULL AS [InGate]
				, NULL AS [DaysCharged]
				, NULL AS [VendorCharge]
				, NULL AS [CustAdmFee]
				, NULL AS [CustomerCharge]
				, NULL AS [DivCharge]
				, NULL AS [FT]
				, NULL AS [LineItemStatus]
				, NULL AS [Status]
				, NULL AS [Reason]
				, NULL AS [Description]
				, NULL AS [VendorName]
				, NULL AS [InvoiceModId]
				, NULL AS [RefNum]
				, NULL AS [ARInvNum]
				, NULL AS [APInvNum]
				, D.APInvDate
				, NULL AS [BillToName]
				, NULL AS [EntryDate]
				, E.Code AS [Company]
				, NULL AS [LastUpdate]
				, NULL AS [LastStatus]
				, D.VendorID
				, D.TotalInvoice
				, D.SentToGP
				, NULL AS [DisputedCharge]
				, NULL AS [ARInvDate]
				, NULL AS [TmpStatus]
				, NULL AS [CustInvDate]
				, NULL AS [NotifyDate]
				, NULL AS [Dispute]
				, (SELECT MAX(newNotes) FROM InvoiceDetail ID WHERE ID.InvoiceNum = D.InvoiceNum AND (CAST(ID.STATUS AS Varchar) + ID.LineItemStatus) IN (SELECT * FROM dbo.F_TBL_VALS_FROM_STRING(@critStatus))) AS [newNotes]
		FROM	(
				SELECT	C.CompanyID 
						, C.InvoiceNum
						, C.APInvDate
						, C.VendorID
						, SUM(C.TotalCharged - C.CanCheck) AS [TotalInvoice]
						, SUM(AccumulatorP) AS [SentToGP]
						, MAX(C.newNotes) AS [newNotes]
				FROM	(
						SELECT	A.CompanyID 
								,A.InvoiceNum
								,CONVERT(Varchar(10), B.InvoiceDate, 101) AS [APInvDate]
								,B.VendorID
								,A.TotalCharged
								,CASE WHEN A.[Status] IN (-140,3) THEN TotalCharged ELSE 0 END AS [AccumulatorP]
								,CASE WHEN A.[Status] = 4 THEN A.TotalCharged ELSE 0 END AS [CanCheck]
								,A.NewNotes
						FROM	InvoiceDetail A
								INNER JOIN @tblInvoices I ON A.InvoiceNum = I.InvoiceNum
								LEFT OUTER JOIN InvoiceMaster B ON A.CompanyID = B.CompanyID AND A.InvoiceNum = B.InvoiceNum
						) C
				GROUP BY 
						C.CompanyID, 
						C.InvoiceNum, 
						C.APInvDate, 
						C.VendorID
				) D
				LEFT OUTER JOIN Drivers.dbo.Companies E ON D.CompanyID = E.ID
		WHERE	D.TotalInvoice <> D.SentToGP
				AND D.INVOICENUM IN (SELECT InvoiceNum FROM @tblInvoices)
	UNION ALL
	SELECT	'2' AS [RowType]
			, A.CompanyID AS [CompanyID]
			, B.InvoiceDate AS [InvoiceDate]
			, A.InvoiceNum AS [InvoiceNum]
			, A.LineItemNo AS [LineItemNo]
			, ISNULL(C.DivisionNum, A.DivisionNum) AS [Div]
			, ISNULL(C.ProNum, A.ProNum) AS [Pro]
			, ISNULL(C.EquipmentID, (CASE WHEN B.EquipTypeID = 2 THEN A.EquipmentID ELSE '' END)) AS [Container] 
			, ISNULL(C.BillToCustomer, A.BillToCustomer) AS [BillTo]
			, ISNULL(C.Consignee, A.Consignee) AS [Consignee]
			, CONVERT(Varchar(10), ISNULL(C.OutGateDate, A.OutGateDate), 101) AS [OutGate]
			, CONVERT(Varchar(10), ISNULL(C.InGateDate, A.InGateDate), 101) AS [InGate]
			, ISNULL(C.DaysCharged, (CASE WHEN A.DaysCharged IS NULL THEN 0 ELSE A.DaysCharged END)) AS [DaysCharged]
			, ISNULL(C.VendorCharge, A.TotalCharged) AS [VendorCharge]
			, ISNULL(C.CustAdmFee, A.CustAdmFee) AS [CustAdmFee]
			, ISNULL(C.CustomerCharge, (A.CustBillAmt + A.CustAdmFee)) AS [CustomerCharge]
			, ISNULL(C.DivChargeAmt, A.DivChargeAmt) AS [DivCharge]
			, ISNULL(C.FT, A.FreeTime) AS [FT]
			, ISNULL(C.[Status], A.LineItemStatus) AS [LineItemStatus]
			, A.[Status]
			, ISNULL(C.Reason, A.Reason) AS [Reason]
			, ISNULL(C.Description, A.GLDescription) AS [Description]
			, B.VendorName
			, C.InvoiceModId
			, ISNULL(C.RefNum, A.RefNum) AS [RefNum]
			, CASE WHEN C.InvoiceModId IS NULL AND C.CustInvNum IS NULL THEN A.CustInvNum ELSE C.CustInvNum END AS [ARInvNum] --pab 1/29/13
			, A.InvoiceNum AS [APInvNum]
			, CONVERT(Varchar(10), B.InvoiceDate, 101) AS [APInvDate]
			, CASE WHEN C.InvoiceModId IS NULL 
				  THEN (CASE WHEN LEN(RTRIM(A.BillToCustomer)) > 1 THEN dbo.PROPER(F.CUSTNAME) + ' (' + RTRIM(A.BillToCustomer) + ')' ELSE NULL END)
				  ELSE (CASE WHEN LEN(RTRIM(C.BillToCustomer)) > 1 THEN dbo.PROPER(E.CUSTNAME) + ' (' + RTRIM(C.BillToCustomer) + ')' ELSE NULL END)
			  END AS [BillToName]
			, CONVERT(varchar(30), A.CreatedDate, 100) AS [EntryDate]
			, D.Code AS [Company]
			, CONVERT(varchar(10),C.ChangedDate, 101) AS [LastUpdate]
			, CASE	WHEN A.[Status] IN (-140,3) THEN 'Posted to GP'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) IN ('N','B') AND A.[Status] = '1' THEN 'Direct Bill'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'N' AND A.[Status] = '-100' THEN 'Accept - No Exceptions'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'D' AND A.[Status] = '-120' THEN 'Dispute - Operations'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'D' AND A.[Status] = '1' THEN 'Dispute - Accounting'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'E' THEN 'Accept - w/ Exceptions'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'P' AND A.[Status] = '1' THEN 'Pending'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'U' AND A.[Status] = '-100' AND A.LineItemStatus = 'P' THEN 'Pending' --added 6/22/2012 pab
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'P' AND A.[Status] = '0' THEN 'Review'
					WHEN (CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'C' THEN 'Cancelled'
			  END AS [LastStatus]
			, NULL AS [VendorID]
			, NULL AS [TotalInvoice]
			, NULL AS [SentToGP]
			, CASE WHEN C.InvoiceModId IS NOT NULL AND A.LineItemStatus = 'D' THEN C.VendorCharge 
			       WHEN A.LineItemStatus = 'D' OR A.[Status] = -120 THEN A.TotalCharged ELSE 0.00 
			  END AS [DisputedCharge]
			, CASE WHEN (
			  CASE WHEN (C.InvoiceModId IS NULL OR C.CustInvDate IS NULL) THEN (CASE WHEN A.CustInvDate IS NOT NULL THEN CONVERT(varchar(10), A.CustInvDate, 101) ELSE NULL END) 
				  ELSE CONVERT(varchar(10), C.CustInvDate, 101) END) IS NULL THEN CONVERT(varchar(10), GetDate(), 101) END AS [ARInvDate]
			, CASE WHEN A.[Status] = 3 THEN '3' ELSE 
				(RTRIM(CAST(A.[Status] AS varchar(5))) + CASE WHEN C.InvoiceModId IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END) END AS [TmpStatus]
			, CASE WHEN (
			  CASE WHEN (C.InvoiceModId IS NULL OR C.CustInvDate IS NULL) THEN (CASE WHEN A.CustInvDate IS NOT NULL THEN CONVERT(varchar(10), A.CustInvDate, 101) ELSE NULL END) 
				  ELSE CONVERT(varchar(10), C.CustInvDate, 101) END) IS NULL THEN CONVERT(varchar(10), GetDate(), 101) END AS [CustInvDate]
			, CONVERT(varchar(10), A.NotifyDate, 101) AS [NotifyDate]
			, ISNULL(C.Dispute, A.Dispute) AS [Dispute]
			, A.newNotes
	FROM	InvoiceDetail A
			LEFT OUTER JOIN InvoiceMaster B ON A.CompanyID = B.CompanyID and A.InvoiceNum = B.InvoiceNum
			LEFT OUTER JOIN (
							SELECT	A.* 
							FROM	Accounting.dbo.InvoiceMod A
									INNER JOIN @tblInvoiceIds C ON A.CompanyID = C.CompanyID AND A.InvoiceNum = C.InvoiceNum AND A.LineItemNo = C.LineItemNo
							) C ON A.CompanyID = C.CompanyID AND A.InvoiceNum = C.InvoiceNum AND A.LineItemNo = C.LineItemNo
			LEFT OUTER JOIN Drivers.dbo.Companies D ON A.CompanyID = D.ID
			LEFT OUTER JOIN Customers F ON A.CompanyID = F.Company and A.BillToCustomer = F.CUSTNMBR
			LEFT OUTER JOIN Customers E ON C.CompanyID = E.Company and C.BillToCustomer = E.CUSTNMBR
	WHERE	A.InvoiceNum IN (
								SELECT	DISTINCT(A.InvoiceNum) AS [InvoiceNum]
								FROM	InvoiceDetail A
										LEFT OUTER JOIN InvoiceMaster B ON (A.CompanyID = B.CompanyID and A.InvoiceNum = B.InvoiceNum)
										LEFT OUTER JOIN (
														SELECT	A.* 
														FROM	Accounting.dbo.InvoiceMod A
																INNER JOIN @tblInvoiceIds C ON A.CompanyID = C.CompanyID AND A.InvoiceNum = C.InvoiceNum AND A.LineItemNo = C.LineItemNo
														) C ON (A.CompanyID = C.CompanyID and A.InvoiceNum = C.InvoiceNum and A.LineItemNo = C.LineItemNo)
								WHERE	A.LineItemStatus <> 'B'
										AND A.[Status] NOT IN (2,3,4,100,-130,-140) --pab 5/7/2013
										AND (@InvoiceNum = NULL OR A.InvoiceNum = @InvoiceNum)
								) 
			AND (@critContainer IS NULL OR ((C.EquipmentID LIKE @critContainer) OR (A.EquipmentID LIKE @critContainer)))
			AND (@critPro IS NULL OR ((C.ProNum LIKE @critPro) OR (A.ProNum LIKE @critPro)))
			AND (@critDiv IS NULL OR (ISNULL(C.DivisionNum, A.DivisionNum) = @critDiv) )
			AND (@critBillTo IS NULL OR ((ISNULL(C.BillToCustomer,A.BillToCustomer) LIKE ('%'+ @critBillTo))))
			AND (@critVendor IS NULL OR (B.VendorID LIKE @critVendor))
			AND (@critARInv IS NULL OR (A.CustInvNum LIKE @critARInv))
			AND (@critStatus IS NULL OR (CASE WHEN A.[Status] = 3 THEN '3' ELSE (RTRIM(CAST( A.[Status] AS varchar(5))) + RTRIM(CASE WHEN C.InvoiceModId IS NULL THEN A.LineItemStatus ELSE C.[Status] END)) END IN --pab 5/7/2013	
				(SELECT * FROM dbo.F_TBL_VALS_FROM_STRING(@critStatus))))
			) Q
	WHERE	(@critCompany IS NULL OR (Q.CompanyID = @critCompany))
			AND (@critAPInv IS NULL OR (Q.InvoiceNum LIKE @critAPInv))
	ORDER BY 
			Q.CompanyID, 
			Q.InvoiceNum, 
			Q.RowType, 
			Q.LineItemNo
END