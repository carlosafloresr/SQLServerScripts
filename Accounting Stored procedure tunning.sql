DECLARE @InvoiceNum nvarchar(50) = NULL
	, @critCompany int = 4
	, @critContainer nvarchar(50) = NULL
	, @critChassis nvarchar(50) = NULL
	, @critPro nvarchar(15) = NULL
	, @critAPInv nvarchar(20) = NULL
	, @critARInv varchar(50) = NULL
	, @critDiv nvarchar(5) = NULL
	, @critVendor nvarchar(12) = NULL
	, @critBillTo nvarchar(6) = NULL
	, @critDate nvarchar(2) = NULL
	, @critFrom datetime = NULL
	, @critTo datetime = NULL
	, @critStatus varchar(50) = '1P'

IF @critDiv = '95'
	SET @critCompany = NULL
SELECT	DISTINCT *,
		CASE WHEN (@InvoiceNum = NULL OR Q.InvoiceNum = @InvoiceNum) AND Q.RowType = 1 THEN 1 ELSE 0 END AS [Sign]
FROM	(
		SELECT	'1' AS [RowType]
				, C.CompanyID 
				, NULL AS [InvoiceDate]
				, C.InvoiceNum
				, NULL AS [LineItemNo]
				, NULL AS [Div]
				, NULL AS [Pro]
				, NULL AS [Container]
				, NULL AS [BillTo]
				, NULL AS [Consignee]
				, NULL AS [OutGate]
				, NULL AS [InGate]
				, NULL AS [DaysCharged]
				, NULL AS [TotalCharged]
				, NULL AS [CustAdmFee]
				, NULL AS [CustomerCharge]
				, NULL AS [DivChargeAmt]
				, NULL AS [FT]
				, NULL AS [LineItemStatus]
				, NULL AS [Status]
				, NULL AS [Reason]
				, NULL AS [Description]
				, NULL AS [VendorName]
				, NULL AS [ChassisDetailMod_ID]
				, NULL AS [RefNum]
				, NULL AS [ARInvNum]
				, NULL AS [APInvNum]
				, C.APInvDate
				, NULL AS [BillToName]
				, NULL AS [EntryDate]
				, CASE C.CompanyID WHEN 1 THEN 'IMCG' WHEN 2 THEN 'GIS' WHEN 4 THEN 'AIS' WHEN 5 THEN 'OIS' WHEN 3 THEN 'PTS' WHEN 6 THEN 'HMIS' WHEN 7 THEN 'DNJ' WHEN 9 THEN 'IGS' ELSE 'NDS' END AS [Company]
				, NULL AS [LastUpdate]
				, NULL AS [LastStatus]
				, C.VendorID
				, SUM(C.Charges - C.CanCheck) AS [TotalInvoice]
				, SUM(AccumulatorP) AS [SentToGP]
				, NULL AS [DisputedCharge]
				, NULL AS [ARInvDate]
				, NULL AS [TmpStatus]
				, NULL AS [CustInvDate]
				, NULL AS [NotifyDate]
				, NULL AS [SWSDateOut]
				, NULL AS [SWSDateIn]
				, NULL AS [VendorDays]
				, NULL AS [SWSDays]
				, NULL AS [Chassis]
				, NULL AS [SWSCharges]
				, NULL AS [Credited]
				, NULL AS [CntOwner]
				, NULL AS [Profit]
				, NULL AS [AltShip]
				, NULL AS [AltName]
				, NULL AS [OutLocation]
				, NULL AS [InLocation]
				, NULL AS [OrigLPCode]
				, NULL AS [OrigName]
				, NULL AS [ONRP]
				, NULL AS [DestLPCode]
				, NULL AS [DestName]
				, NULL AS [DNRP]
				, NULL AS [Rate]
				, NULL AS [SWSRate]
				, NULL AS [NewCharge]
				, NULL AS [AmountPaid]
				, NULL AS [AmountDisputed]
				, NULL AS [Adjustment]
				, NULL AS [GLNum]
				, NULL AS [GLDescription]
				, NULL AS [PostDate]
				, NULL AS [Contact]
				, NULL AS [Notes]
				, NULL AS [SWSRefNum]
				, NULL AS [ChassisDetail_ID]
				, NULL AS [FK_ChassisHeaderID]
				, NULL AS [VendorCode]
				, NULL AS [ChztotVn]
		FROM	(
				SELECT	A.CompanyID 
						, A.InvoiceNum
						, CASE WHEN B.InvoiceDate IS NOT NULL THEN CONVERT(varchar(10), B.InvoiceDate, 101) ELSE NULL END AS [APInvDate]
						, B.VendorID
						, A.Charges
						, CASE WHEN [Status] IN (-140,3) THEN Charges ELSE 0 END AS [AccumulatorP]
						, CASE WHEN A.[Status] = 4 THEN A.Charges ELSE 0 END AS [CanCheck]
				FROM	ChassisDetail A 
						LEFT OUTER JOIN ChassisHeader B ON A.FK_ChassisHeaderID = B.ChassisHeaderID
				WHERE	A.InvoiceNum IN (SELECT	DISTINCT(A.InvoiceNum) AS [InvoiceNum]
											FROM	ChassisDetail A
												LEFT OUTER JOIN ChassisHeader B ON A.FK_ChassisHeaderID = B.ChassisHeaderID
												LEFT OUTER JOIN (SELECT	FK_ChassisDetail_ID, ContainerID, ChassisID, ProNum, Division, Custno, ChassisDetailMod_ID, [Status], LineItemStatus 
																FROM	Accounting.dbo.ChassisDetailMod
																WHERE	ChassisDetailMod_ID IN (
																								SELECT	MAX(ChassisDetailMod_ID) AS [ChassisDetailMod_ID]
																								FROM	Accounting.dbo.ChassisDetailMod
																								WHERE	@critCompany IS NULL OR (CompanyID = @critCompany)
																								GROUP BY CompanyID, InvoiceNum, FK_ChassisDetail_ID
																								)
																) C ON A.ChassisDetail_ID = C.FK_ChassisDetail_ID
												LEFT OUTER JOIN Drivers.dbo.Companies D ON (A.CompanyID = D.ID)					
												LEFT OUTER JOIN ILSGP01.GPCustom.dbo.View_CustomerMaster F ON A.CompanyID = F.CompanyNumber AND A.CustNo = F.CUSTNMBR
										WHERE	(@critContainer IS NULL OR ((C.ContainerID LIKE @critContainer) OR (A.ContainerID LIKE @critContainer)))
												AND (@critChassis IS NULL OR ((C.ChassisID LIKE @critChassis) OR (A.ChassisID LIKE @critChassis)))
												AND (@critPro IS NULL OR ((C.ProNum LIKE @critPro) OR (A.ProNum LIKE @critPro)))
												AND (@critDiv IS NULL OR (ISNULL(C.Division, A.Division) = @critDiv) )
												AND (@critBillTo IS NULL OR ((C.CustNo LIKE @critBillTo) OR (A.CustNo LIKE @critBillTo)))
												AND (@critVendor IS NULL OR (B.VendorID = @critVendor))
												AND (@critARInv IS NULL OR (A.CustInvNum LIKE @critARInv))
												AND (@critDate IS NULL OR 
												(@critDate IS NOT NULL AND (@critFrom IS NULL OR @critTo IS NULL) OR
												((@critDate = 'AP' AND B.InvoiceDate BETWEEN @critFrom AND @critTo) OR 
												(@critDate = 'AR' AND A.CustInvDate BETWEEN @critFrom AND @critTo))))
												AND (@critStatus IS NULL OR CASE WHEN C.ChassisDetailMod_ID IS NULL THEN RTRIM(CAST(A.[Status] AS varchar(5))) +  RTRIM(A.LineItemStatus) ELSE RTRIM(CAST(C.[Status] AS varchar(5))) + RTRIM(C.LineItemStatus) END IN ('1P')))
										) C
										GROUP BY C.APInvDate, C.CompanyID, C.InvoiceNum, C.VendorID
UNION ALL
Select '2' AS [RowType]
			, A.CompanyID AS [CompanyID]
			, B.InvoiceDate AS [InvoiceDate]
			, A.InvoiceNum AS [InvoiceNum]
			, A.LineItemNo AS [LineItemNo]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Division ELSE C.Division END AS [Div]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ProNum ELSE C.ProNum END AS [Pro]
			, '<a href="Chassis_ViewSWS.aspx?cn=' + CAST(A.CompanyID AS nvarchar(2)) + '&ct=' + CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ContainerID  ELSE C.ContainerID  END 
			+ '" onclick="window.open(this.href, ''mywin'',''left=20,top=20,width=1000,height=250,toolbar=1,resizable=0,scrollbars=1''); return false;">' 
				+ CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ContainerID  ELSE C.ContainerID  END + '</a>' AS [Container]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.CustNo ELSE C.CustNo END AS [BillTo]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Consignee  ELSE C.Consignee  END AS [Consignee]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN (CASE WHEN A.DateOut IS NOT NULL THEN CONVERT(varchar(10), A.DateOut, 101) ELSE NULL END) 
				   ELSE CONVERT(varchar(10), C.DateOut, 101) END AS [OutGate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN (CASE WHEN A.DateIn IS NOT NULL THEN CONVERT(varchar(10), A.DateIn, 101) ELSE NULL END) 
				   ELSE CONVERT(varchar(10), C.DateIn, 101) END AS [InGate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN (CASE WHEN A.BillableDays IS NULL THEN 0 ELSE A.BillableDays END) ELSE C.BillableDays END AS [DaysCharged]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Charges ELSE C.Charges END AS [TotalCharged]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.CustAdmFee ELSE (CASE WHEN C.CustAdmFee IS NULL THEN A.CustAdmFee ELSE C.CustAdmFee END) END AS [CustAdmFee]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN (A.CustBillAmt + A.CustAdmFee) ELSE (C.CustBillAmt + C.CustAdmFee) END AS [CustomerCharge]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.DivChargeAmt ELSE C.DivChargeAmt END AS [DivChargeAmt]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Qty ELSE C.Qty END AS [FT]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END AS [LineItemStatus]
			--, A.[Status]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.[Status] ELSE C.[Status] END AS [Status]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Notes ELSE C.Notes END AS [Reason]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.GLDescription ELSE C.GLDescription END AS [Description]
			, B.VendorName
			, C.ChassisDetailMod_ID
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.RefNo ELSE C.RefNo END AS [RefNum]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL AND C.CustInvNum IS NULL THEN A.CustInvNum ELSE C.CustInvNum END AS [ARInvNum] 
			, A.InvoiceNum AS [APInvNum]
			, CASE WHEN B.InvoiceDate IS NOT NULL THEN CONVERT(varchar(10), B.InvoiceDate, 101) ELSE NULL END AS [APInvDate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL 
			  THEN (CASE WHEN LEN(RTRIM(A.CustNo)) > 1 THEN RTRIM(dbo.PROPER(F.CustName)) + ' (' + RTRIM(A.CustNo) + ')' ELSE NULL END)
			  ELSE (CASE WHEN LEN(RTRIM(C.CustNo)) > 1 THEN RTRIM(dbo.PROPER(E.CustName)) + ' (' + RTRIM(C.CustNo) + ')' ELSE NULL END)
			  END AS [BillToName]
			, CONVERT(varchar(30), A.CreatedDate, 100) AS [EntryDate]
			, D.Code AS [Company]
			, CONVERT(varchar(10), C.CreatedDate, 101) AS [LastUpdate]
			, CASE WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) ='B' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 3 THEN 'Posted to GP'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) IN ('N','B') AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 1 THEN 'Billed in Manifest'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'N' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = -100 THEN 'Debit Memo'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'D' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = -120 THEN 'Dispute - Requested'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'D' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 1 THEN 'Dispute - Filed'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'E' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = -110 THEN 'Charge Div'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'P' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 1 THEN 'Ops Review'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'D' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END)= 2 THEN 'Dispute - Dup Billing' 
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'P' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END)= -150 THEN 'Prepaid'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'B' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END)= 2 THEN 'Ready to Post' 
				--WHEN (CASE WHEN C.ChassisDetailMod_ID IS NOT NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'P' AND A.[Status] = '1' THEN 'Sent to Client'
				--WHEN (C.ChassisDetailMod_ID IS NULL AND A.LineItemStatus = 'P' AND A.[Status] = '1') THEN 'Pending'
				--WHEN (C.ChassisDetailMod_ID IS NOT NULL AND C.[Status] = 'P' AND A.[Status] = '1') THEN 'Sent to Client'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'P' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 0 THEN 'Review'
				WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) = 'C' AND (CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.[Status] ELSE C.[Status] END) = 4 THEN 'Cancelled'
			  END AS [LastStatus]
			, NULL AS [VendorID]
			, NULL AS [TotalInvoice]
			, NULL AS [SentToGP]
			--, CASE WHEN C.ChassisDetailMod_ID IS NOT NULL AND A.LineItemStatus = 'D' THEN C.Charges 
			--       WHEN A.LineItemStatus = 'D' OR A.[Status] = -120 THEN A.Charges ELSE 0.00 
			--  END AS [DisputedCharge]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL AND A.LineItemStatus = 'D' THEN A.Charges 
			      WHEN C.ChassisDetailMod_ID IS NOT NULL AND C.LineItemStatus = 'D' THEN C.Charges ELSE 0.00 
			  END AS [DisputedCharge]
			--, CASE WHEN C.ChassisDetailMod_ID IS NULL AND (CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'D' THEN A.TotalCharged 
			--		WHEN (CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.LineItemStatus ELSE C.[Status] END) = 'D' THEN C.CustomerCharge ELSE 0
			--		END AS [DisputedCharge]
			--, CASE WHEN C.ChassisDetailMod_ID IS NULL AND C.CustInvDate IS NULL THEN CONVERT(varchar(10), GetDate(), 101) ELSE CONVERT(varchar(10), C.CustInvDate, 101) END AS [ARInvDate]
			, CASE WHEN (
			  CASE WHEN (C.ChassisDetailMod_ID IS NULL OR C.CustInvDate IS NULL) THEN (CASE WHEN A.CustInvDate IS NOT NULL THEN CONVERT(varchar(10), A.CustInvDate, 101) ELSE NULL END) 
				  ELSE CONVERT(varchar(10), C.CustInvDate, 101) END) IS NULL THEN CONVERT(varchar(10), GetDate(), 101) END AS [ARInvDate]
			, CASE WHEN ISNULL(C.[Status], A.[Status]) = 3 THEN '3' ELSE 
				(RTRIM(CAST(ISNULL(C.[Status], A.[Status]) AS varchar(5))) + CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.LineItemStatus IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END) END AS [TmpStatus]
			, CASE WHEN (
			  CASE WHEN (C.ChassisDetailMod_ID IS NULL OR C.CustInvDate IS NULL) THEN (CASE WHEN A.CustInvDate IS NOT NULL THEN CONVERT(varchar(10), A.CustInvDate, 101) ELSE NULL END) 
				  ELSE CONVERT(varchar(10), C.CustInvDate, 101) END) IS NULL THEN CONVERT(varchar(10), GetDate(), 101) END AS [CustInvDate]
				  --, CASE WHEN C.ChassisDetailMod_ID IS NULL AND C.CustInvDate IS NULL THEN CONVERT(varchar(10), GetDate(), 101) ELSE CONVERT(varchar(10), C.CustInvDate, 101) END AS [CustInvDate]
			, CONVERT(varchar(10), A.CreatedDate, 101) AS [NotifyDate]
			--, A.NotifyDate
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN CONVERT(varchar(10), A.[SWSDateOut], 101) ELSE CONVERT(varchar(10), C.[SWSDateOut], 101) END AS [SWSDateOut]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN CONVERT(varchar(10), A.[SWSDateIn], 101) ELSE CONVERT(varchar(10), C.[SWSDateIn], 101) END AS [SWSDateIn]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.BillableDays  ELSE C.Billabledays  END AS [VendorDays]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Qty  ELSE C.Qty  END AS [SWSDays]
			--, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ChassisID  ELSE C.ChassisID  END AS [Chassis]
			, '<a href="Chassis_ViewSWS.aspx?cn=' + CAST(A.CompanyID AS nvarchar(2)) + '&ch=' + CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ChassisID  ELSE C.ChassisID  END 
			+ '" onclick="window.open(this.href, ''mywin'',''left=20,top=20,width=1000,height=250,toolbar=1,resizable=0,scrollbars=1''); return false;">' 
				+ CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ChassisID  ELSE C.ChassisID  END + '</a>' AS [Chassis]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.SWSCharges  ELSE C.SWSCharges  END AS [SWSCharges]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Credited  ELSE C.Credited  END AS [Credited]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.CntOwner  ELSE C.CntOwner  END AS [CntOwner]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN (ISNULL(A.SWSCharges, 0)-ISNULL(A.Charges, 0))  ELSE (ISNULL(A.SWSCharges, 0)-ISNULL(A.Charges, 0))  END AS [Profit] 
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.AltShip  ELSE C.AltShip  END AS [AltShip]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.AltName  ELSE C.AltName  END AS [AltName]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.OutLocation  ELSE C.OutLocation  END AS [OutLocation]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ReturnLocation  ELSE C.ReturnLocation  END AS [InLocation]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.OrigLPCode  ELSE C.OrigLPCode  END AS [OrigLPCode]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.OrigName  ELSE C.OrigName  END AS [OrigName]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.ONRP  ELSE C.ONRP  END AS [ONRP]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.DestLPCode  ELSE C.DestLPCode  END AS [DestLPCode]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.DestName  ELSE C.DestName  END AS [DestName]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.DNRP  ELSE C.DNRP  END AS [DNRP]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Rate  ELSE C.Rate  END AS [Rate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.SWSRate  ELSE C.SWSRate  END AS [SWSRate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.NewCharge  ELSE C.NewCharge  END AS [NewCharge]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.AmountPaid  ELSE C.AmountPaid  END AS [AmountPaid]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.AmountDisputed  ELSE C.AmountDisputed  END AS [AmountDisputed]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Adjustment  ELSE C.Adjustment  END AS [Adjustment]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.GLNum  ELSE C.GLNum  END AS [GLNum]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.GLDescription  ELSE C.GLDescription  END AS [GLDescription]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.PostDate  ELSE C.Postdate  END AS [PostDate]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Contact  ELSE C.Contact  END AS [Contact]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.Notes  ELSE C.Notes  END AS [Notes]
			, CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.SWSRefNo  ELSE C.SWSRefNo  END AS [SWSRefNum]
			, A.ChassisDetail_ID
			, A.FK_ChassisHeaderID
			, A.VendorID AS [VendorCode]
			, A.[ChztotVn]
		FROM ChassisDetail A WITH(NOLOCK)
		LEFT OUTER JOIN ChassisHeader B WITH(NOLOCK)
		ON A.FK_ChassisHeaderID = B.ChassisHeaderID--(A.CompanyID = B.CompanyID and A.InvoiceNum = B.InvoiceNum)
		LEFT OUTER JOIN (
			SELECT * FROM Accounting.dbo.ChassisDetailMod WITH(NOLOCK)
			WHERE ChassisDetailMod_ID IN (
				SELECT MAX(ChassisDetailMod_ID) AS [ChassisDetailMod_ID]
				FROM Accounting.dbo.ChassisDetailMod WITH(NOLOCK)
				GROUP BY CompanyID, InvoiceNum, LineItemNo)
		) C ON (A.CompanyID = C.CompanyID and A.InvoiceNum = C.InvoiceNum and A.LineItemNo = C.LineItemNo)
		LEFT OUTER JOIN ILSSQL01.Drivers.dbo.Companies D WITH(NOLOCK)
		ON (A.CompanyID = D.ID)
		LEFT OUTER JOIN ILSGP01.GPCustom.dbo.View_CustomerMaster F WITH(NOLOCK)
		--ON (A.CompanyID = F.CompanyNumber 
		--AND A.CustNo = F.CUSTNMBR)
		ON (CASE A.CompanyID WHEN 1 THEN 'IMC' WHEN 2 THEN 'GIS' WHEN 4 THEN 'AIS' WHEN 5 THEN 'OIS' WHEN 3 THEN 'PTS' WHEN 6 THEN 'HMIS' WHEN 7 THEN 'DNJ' WHEN 9 THEN 'IGS' ELSE 'NDS' END = F.[CompanyId]
		AND A.CustNo = F.CUSTNMBR)
		LEFT OUTER JOIN ILSGP01.GPCustom.dbo.View_CustomerMaster E WITH(NOLOCK)
		--ON (C.CompanyID = E.CompanyNumber 
		--AND C.CustNo = E.CUSTNMBR)
		ON (CASE A.CompanyID WHEN 1 THEN 'IMC' WHEN 2 THEN 'GIS' WHEN 4 THEN 'AIS' WHEN 5 THEN 'OIS' WHEN 3 THEN 'PTS' WHEN 6 THEN 'HMIS' WHEN 7 THEN 'DNJ' WHEN 9 THEN 'IGS' ELSE 'NDS' END = E.[CompanyId] 
		AND C.CustNo = E.CUSTNMBR)
		WHERE A.InvoiceNum IN (
				SELECT DISTINCT(A.InvoiceNum) AS [InvoiceNum]
				FROM ChassisDetail A WITH(NOLOCK)
				LEFT OUTER JOIN ChassisHeader B WITH(NOLOCK)
				ON A.FK_ChassisHeaderID = B.ChassisHeaderID--(A.CompanyID = B.CompanyID and A.InvoiceNum = B.InvoiceNum)
				LEFT OUTER JOIN (
					SELECT * FROM Accounting.dbo.ChassisDetailMod
					WHERE ChassisDetailMod_ID IN (
						SELECT MAX(ChassisDetailMod_ID) AS [ChassisDetailMod_ID]
						FROM Accounting.dbo.ChassisDetailMod WITH(NOLOCK)
						GROUP BY CompanyID, InvoiceNum, LineItemNo)
				) C ON (A.CompanyID = C.CompanyID and A.InvoiceNum = C.InvoiceNum and A.LineItemNo = C.LineItemNo)
				Left OUTER JOIN ILSSQL01.Drivers.dbo.Companies D WITH(NOLOCK)
				ON (A.CompanyID = D.ID)
				LEFT OUTER JOIN ILSGP01.GPCustom.dbo.View_CustomerMaster F WITH(NOLOCK)
				--ON (A.CompanyID = F.CompanyNumber 
				ON (CASE A.CompanyID WHEN 1 THEN 'IMC' WHEN 2 THEN 'GIS' WHEN 4 THEN 'AIS' WHEN 5 THEN 'OIS' WHEN 3 THEN 'PTS' WHEN 6 THEN 'HMIS' WHEN 7 THEN 'DNJ' WHEN 9 THEN 'IGS' ELSE 'NDS' END = F.[CompanyId]
			AND A.CustNo = F.CUSTNMBR)
			LEFT OUTER JOIN ILSGP01.GPCustom.dbo.View_CustomerMaster E WITH(NOLOCK)
			--ON (C.CompanyID = E.CompanyNumber 
			ON (CASE A.CompanyID WHEN 1 THEN 'IMC' WHEN 2 THEN 'GIS' WHEN 4 THEN 'AIS' WHEN 5 THEN 'OIS' WHEN 3 THEN 'PTS' WHEN 6 THEN 'HMIS' WHEN 7 THEN 'DNJ' WHEN 9 THEN 'IGS' ELSE 'NDS' END = F.[CompanyId]
			AND C.CustNo = E.CUSTNMBR)
				WHERE-- A.LineItemStatus <> 'B'
				  --AND A.[Status] NOT IN (2,4,-130)
				  --AND A.[Status] NOT IN (2,3,4,100,-130,-140) --pab 5/7/2013
				  --AND 
				  --((@InvoiceNum IS NULL) OR (@InvoiceNum IS NOT NULL AND A.InvoiceNum = @InvoiceNum))
				   ((@InvoiceNum = NULL) OR (A.InvoiceNum = @InvoiceNum))
		) 
	    AND (@critContainer IS NULL OR ((C.ContainerID LIKE @critContainer) OR (A.ContainerID LIKE @critContainer)))
		AND (@critChassis IS NULL OR ((C.ChassisID LIKE @critChassis) OR (A.ChassisID LIKE @critChassis)))
	    AND (@critPro IS NULL OR ((C.ProNum LIKE @critPro) OR (A.ProNum LIKE @critPro)))
	    --AND (@critDiv IS NULL OR ((C.DivisionNum = @critDiv) OR (A.DivisionNum = @critDiv))) pab 5/7/2013
		AND (@critDiv IS NULL OR (ISNULL(C.Division, A.Division) = @critDiv) )
	    AND (@critBillTo IS NULL OR ((C.CustNo LIKE @critBillTo) OR (A.CustNo LIKE @critBillTo)))
	    AND (@critVendor IS NULL OR (B.VendorID = @critVendor))
	    AND (@critARInv IS NULL OR (A.CustInvNum LIKE @critARInv))
	    --AND (@critStatus IS NULL OR (CASE WHEN A.[Status] = 3 THEN '3' ELSE (RTRIM(CAST(A.[Status] AS varchar(5))) + RTRIM(CASE WHEN C.ChassisDetailMod_ID IS NULL OR C.[Status] IS NULL THEN A.LineItemStatus ELSE C.[Status] END)) END IN
		--AND (@critStatus IS NULL OR (CASE WHEN A.[Status] = 3 THEN '3' ELSE (RTRIM(CAST( A.[Status] AS varchar(5))) + RTRIM(CASE WHEN C.ChassisDetailMod_ID IS NULL THEN A.LineItemStatus ELSE C.LineItemStatus END)) END IN --pab 5/7/2013	
		AND (@critStatus IS NULL OR CASE WHEN C.ChassisDetailMod_ID IS NULL THEN RTRIM(CAST(A.[Status] AS varchar(5))) +  RTRIM(A.LineItemStatus) ELSE RTRIM(CAST(C.[Status] AS varchar(5))) + RTRIM(C.LineItemStatus) END IN 
			(SELECT * FROM dbo.F_TBL_VALS_FROM_STRING(@critStatus)))--)
			
	) Q
	WHERE (@critCompany IS NULL OR (Q.CompanyID = @critCompany))
	  AND (@critAPInv IS NULL OR (Q.InvoiceNum LIKE @critAPInv))
	--ORDER BY Q.CompanyID, Q.InvoiceNum, Q.RowType, Q.LineItemNo
	ORDER BY Q.APInvDate, Q.CompanyID, Q.InvoiceNum, Q.RowType, Q.LineItemNo
