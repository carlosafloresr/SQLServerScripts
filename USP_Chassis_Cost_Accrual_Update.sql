USE [Accounting]
GO
/****** Object:  StoredProcedure [dbo].[USP_Chassis_Cost_Accrual_Update]    Script Date: 2/3/2021 9:07:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_Chassis_Cost_Accrual_Update
*/
ALTER PROCEDURE [dbo].[USP_Chassis_Cost_Accrual_Update]
AS
DECLARE	@Query		Varchar(1500),
		@StartDate	Date = DATEADD(dd,-7, GETDATE())

BEGIN
	SET NOCOUNT ON;
	--DROP TABLE ##TempAccrualPostgres
	--DROP TABLE #tempChassisDetail
	
	SET @Query =
	'SELECT DISTINCT inv.applyto AS InvoiceNumber,' +
					'inv.btref AS ReferenceNumber,' +
					'inv.cmpy_no AS CompanyId,' +
					'inv.btname AS Customer,' +
					'inv.shname AS Shipper,' +
					'inv.shcityst AS CityState_SH,' +
					'inv.cnname AS Cosignee,' +
					'inv.cncityst AS CityState_CN,' +
					'inv.invdate AS InvoiceDate,' +
					'inv.revtype AS RevenueType,' +
					'chz.total AS Amount_Accrual,' +					
					'inv.customer_billto_id AS BillToID,' +
					'inv.alt_shipper_billto_id AS BillToAltID,' +
					'ord.dmtype AS DM, ' +
					'ord.billch_code AS Chassis,' +
					'ord.billtl_code AS Container,' +
					'ord.billch_eqocode AS Pool,' +
					'ord.billch_upceqocode AS UPC,' +
					'ord.chzstartdt AS OutDate,' +
					'ord.chzstopdt AS InDate ' +
	'FROM trk.invoice inv ' +
	'LEFT JOIN trk.order ord ON inv.or_no = ord.no ' +
	--'LEFT JOIN trk.order ord ON inv.cmpy_no = ord.cmpy_no ' +
	--					   'and inv.div_code = ord.div_code ' +
	--					   'and inv.pro = ord.pro ' +
	--					   'and inv.bt_code = ord.bt_code ' +
	--					   'and inv.eq_code = ord.billtl_code ' +
	'LEFT JOIN trk.invchzpay chz ON inv.cmpy_no = chz.cmpy_no ' +
							   'and inv.code = chz.inv_code ' +
							   'and inv.invdate is not null ' +	
	'WHERE inv.invdate >= ''' + CONVERT(Char(10), @StartDate, 101) + ''' ' +
	 'order by inv.applyto;'
	
	EXECUTE USP_QuerySWS @Query, '##TempAccrualPostgres' 
		
	--Initial update for existing entries with necessary changes
	UPDATE [dbo].[ChassisCostAccrual] SET
		InvoiceNumber	=	tmp.InvoiceNumber,
		ReferenceNumber =	tmp.ReferenceNumber,
		CompanyId		=	tmp.CompanyId,
		Customer		=	tmp.Customer,
		Shipper			=	tmp.Shipper,
		CityState_SH	=	tmp.CityState_SH,
		Cosignee		=	tmp.Cosignee,
		CityState_CN	=	tmp.CityState_CN,
		InvoiceDate		=	tmp.InvoiceDate,
		RevenueType		=	tmp.RevenueType,
		--Amount_Billed	=	tmp.Amount_Billed,
		Amount_Accrual	=	(CASE WHEN tmp.Amount_Accrual = 0.0 THEN NULL ELSE tmp.Amount_Accrual END),
		BillToID		=	tmp.BillToID,
		BillToAltID		=	tmp.BillToAltID,
		DM				=	tmp.DM,
		Chassis			=	tmp.Chassis,
		Container		=	tmp.Container,
		Pool			=	tmp.Pool,
		UPC				=	tmp.UPC,
		OutDate			=	tmp.OutDate,
		InDate			=	tmp.InDate
	FROM [dbo].[ChassisCostAccrual] acc
	INNER JOIN ##TempAccrualPostgres tmp ON acc.InvoiceNumber = tmp.InvoiceNumber
	AND acc.InvoiceDate = tmp.InvoiceDate   
	
	--initial insert for new entries
	INSERT INTO [dbo].[ChassisCostAccrual]
	SELECT	tmp.InvoiceNumber,
			tmp.ReferenceNumber,
			tmp.CompanyId,
			cpy.CompanyName AS Company,
			tmp.Customer,
			tmp.Shipper,
			tmp.CityState_SH,
			tmp.Cosignee,
			tmp.CityState_CN,
			tmp.InvoiceDate,
			tmp.RevenueType,
			NULL AS Amount_Billed,
			CASE WHEN tmp.Amount_Accrual = 0.00 THEN NULL
			ELSE tmp.Amount_Accrual
			END as Amount_Accrual,
			NULL AS Amount_Charges,
			NULL AS Amount_Variance,
			NULL AS Vendor,
			tmp.BillToID,
			NULL AS BillTo,
			tmp.BillToAltID,
			NULL AS BillToAlt,
			NULL AS SSL,
			tmp.DM AS DM,
			tmp.Chassis,
			tmp.Container,
			NULL AS SalesType,
			tmp.Pool,
			tmp.UPC,
			tmp.OutDate,
			tmp.InDate,
			NULL AS Status
	FROM ##TempAccrualPostgres tmp
	LEFT JOIN [PRISQL01P].[GPCustom].[dbo].[Companies] cpy ON tmp.CompanyId = cpy.CompanyNumber AND cpy.CompanyId != 'ATEST'
	WHERE NOT EXISTS (
		SELECT TOP 1 acc.InvoiceNumber 
		FROM [dbo].[ChassisCostAccrual] acc
		WHERE acc.InvoiceNumber = tmp.InvoiceNumber
	)

	DROP TABLE ##TempAccrualPostgres 

	--Remove Duplicate Rows
	DELETE [dbo].[ChassisCostAccrual]
	FROM [dbo].[ChassisCostAccrual]
	LEFT OUTER JOIN (
		SELECT	MIN(Id) AS Id, InvoiceNumber, ReferenceNumber
		FROM	[dbo].[ChassisCostAccrual]
		GROUP BY InvoiceNumber, ReferenceNumber) AS KeepRows 
	ON [dbo].[ChassisCostAccrual].Id = KeepRows.Id
	WHERE KeepRows.Id IS Null

	--Update vendor name, SSL, and Status from chassis detail table
	UPDATE [dbo].[ChassisCostAccrual] 
	SET	Vendor	=	det.VendorName,
		SSL		=	det.CntOwner,
		Status	=	det.Status,
		Amount_Billed = (CASE WHEN det.SWSCharges = 0.0 THEN NULL ELSE det.SWSCharges END)
	FROM [dbo].[ChassisCostAccrual] acc
	INNER JOIN [dbo].[ChassisDetail] det ON acc.InvoiceNumber = det.ProNum

	--Update Debit Memo billed sales from chassis detail table
	UPDATE [dbo].[ChassisCostAccrual] 
	SET	SalesType = 'DM'
	FROM [dbo].[ChassisCostAccrual] acc
	INNER JOIN [dbo].[ChassisDetail] det ON acc.InvoiceNumber = det.ProNum
	      AND det.Status = -100 and det.LineItemStatus = 'N' 

	--Table to work on combining latest Charges Amount from either ChassisDetail or ChassisDetailMod tables
	SELECT ChassisDetail_ID, ChassisID, ProNum, Charges
	INTO #tempChassisDetail
	FROM [dbo].[ChassisDetail]

	--Update the temporary table with the latest amounts
	UPDATE #tempChassisDetail 
	SET	Charges = r.Charges
	FROM #tempChassisDetail tmp
	INNER JOIN
	(	
		SELECT DISTINCT z.ChassisDetail_ID, z.Charges
		FROM [dbo].[ChassisDetail] z
		INNER JOIN
		(
			SELECT x.ChassisDetail_ID, MAX(x.CreatedDate) AS CreatedDate
			FROM (
				SELECT det.ChassisDetail_ID, det.Charges, det.CreatedDate
				FROM [dbo].[ChassisDetail] det
				INNER JOIN [dbo].[ChassisDetailMod] cdm ON det.ChassisDetail_ID = cdm.FK_ChassisDetail_ID
				--WHERE det.pronum = '11-204047'
				UNION ALL
				SELECT det.ChassisDetail_ID, cdm.Charges, cdm.CreatedDate
				FROM [dbo].[ChassisDetail] det
				INNER JOIN [dbo].[ChassisDetailMod] cdm ON det.ChassisDetail_ID = cdm.FK_ChassisDetail_ID
				--where det.pronum = '11-204047'
			) AS x
			GROUP BY x.ChassisDetail_ID
		) y ON y.ChassisDetail_ID = z.ChassisDetail_ID AND y.CreatedDate = z.CreatedDate
		UNION ALL
		SELECT distinct z.FK_ChassisDetail_ID AS ChassisDetail_ID, z.Charges
		FROM [dbo].[ChassisDetailMod] z
		INNER JOIN
		(
			SELECT x.ChassisDetail_ID, MAX(x.CreatedDate) AS CreatedDate
			FROM (
				SELECT det.ChassisDetail_ID, det.Charges, det.CreatedDate
				FROM [dbo].[ChassisDetail] det
				INNER JOIN [dbo].[ChassisDetailMod] cdm ON det.ChassisDetail_ID = cdm.FK_ChassisDetail_ID
				UNION ALL
				SELECT det.ChassisDetail_ID, cdm.Charges, cdm.CreatedDate
				FROM [dbo].[ChassisDetail] det
				INNER JOIN [dbo].[ChassisDetailMod] cdm ON det.ChassisDetail_ID = cdm.FK_ChassisDetail_ID
			) AS x
			GROUP BY x.ChassisDetail_ID
		) y ON y.ChassisDetail_ID = z.FK_ChassisDetail_ID AND y.CreatedDate = z.CreatedDate
	) r ON tmp. ChassisDetail_ID = r.ChassisDetail_ID

	--Update Charges on ChassisCostAccrual
	UPDATE [dbo].[ChassisCostAccrual] SET
		Amount_Charges	=	(CASE WHEN tmp.Amount_Charges = 0.0 THEN NULL ELSE tmp.Amount_Charges END)
	From [dbo].[ChassisCostAccrual] acc
	INNER JOIN (
		SELECT	ProNum, ChassisID, SUM(Charges) AS	Amount_Charges
		FROM #tempChassisDetail
		WHERE ISNULL(ProNum, '') != ''
		GROUP BY ProNum, ChassisID
	) tmp ON acc.InvoiceNumber = tmp.ProNum
	AND (acc.Chassis = tmp.ChassisID OR acc.Chassis = 'CHASSIS')

	DROP TABLE #tempChassisDetail

	--Update Company Name for NDS Agents
	UPDATE [dbo].[ChassisCostAccrual] 
	SET	CompanyId = cpy.CompanyNumber,
		Company = cpy.CompanyName
	FROM [dbo].[ChassisCostAccrual] acc
	INNER JOIN [PRISQL01P].[GPCustom].[dbo].[Agents] agt ON acc.CompanyId = agt.Agent
	INNER JOIN [PRISQL01P].[GPCustom].[dbo].[Companies] cpy ON cpy.CompanyId = agt.Company

	--Update Customer and alt Customer Names from Customer Master table
	UPDATE [dbo].[ChassisCostAccrual] 
	SET	BillTo		=	LTRIM(RTRIM(bto.Customer)),
		BillToAlt	=	LTRIM(RTRIM(alt.Customer))
	FROM [dbo].[ChassisCostAccrual] acc
	LEFT JOIN (
		SELECT	cm.CustName AS Customer, 
				cpy.CompanyNumber AS CompanyNumber, 
				cm.CustNmbr AS CustomerNumber
		FROM [PRISQL01P].[GPCustom].[dbo].[CustomerMaster] cm
		INNER JOIN [PRISQL01P].[GPCustom].[dbo].[Companies] cpy ON cm.CompanyId = cpy.CompanyId
	) bto ON bto.CompanyNumber = REPLACE(SUBSTRING(acc.BillToId, 1, 4), '-','')
		 and bto.CustomerNumber = REPLACE(SUBSTRING(acc.BillToId, 5, 12), '-','')
	LEFT JOIN (
		SELECT	cm.CustName AS Customer, 
				cpy.CompanyNumber AS CompanyNumber, 
				cm.CustNmbr AS CustomerNumber
		FROM [PRISQL01P].[GPCustom].[dbo].[CustomerMaster] cm
		INNER JOIN [PRISQL01P].[GPCustom].[dbo].[Companies] cpy ON cm.CompanyId = cpy.CompanyId
	) alt ON alt.CompanyNumber = REPLACE(SUBSTRING(acc.BillToAltId, 1, 4), '-','')
		 AND alt.CustomerNumber = REPLACE(SUBSTRING(acc.BillToAltId, 5, 12), '-','')

	 --Update Variance Amount 1
	 UPDATE [dbo].[ChassisCostAccrual] SET
		Amount_Variance = acc.Amount_Accrual
	FROM [dbo].[ChassisCostAccrual] acc
	WHERE	acc.Amount_Charges IS  NULL 

	  --Update Variance Amount 2
	 UPDATE [dbo].[ChassisCostAccrual] SET
		Amount_Variance = acc.Amount_Charges
	FROM [dbo].[ChassisCostAccrual] acc
	WHERE	acc.Amount_Accrual IS  NULL  

	 --Update Variance Amount 3
	UPDATE [dbo].[ChassisCostAccrual] SET
		Amount_Variance = ABS(acc.Amount_Accrual - acc.Amount_Charges)
	FROM [dbo].[ChassisCostAccrual] acc
	WHERE	acc.Amount_Accrual IS  NOT NULL
	and		acc.Amount_Charges IS  NOT NULL 

	--Clean Up entries with NO Accrual and NO Charges and NO Variance
	--or Status is not 3 (Posted to Great Plains)
	DELETE FROM [dbo].[ChassisCostAccrual]
	WHERE	(Amount_Accrual IS NULL
	AND		Amount_Charges IS NULL)
	AND		Amount_Variance IS NULL
	OR ((Amount_Accrual = 0.00 OR Amount_Charges = 0.00) AND Amount_Variance = 0.00)
	OR ((Amount_Accrual != 0.00 AND Amount_Charges != 0.00) AND Amount_Variance = 0.00)
--	OR (Status != 3 AND Amount_Accrual IS NOT NULL)
	OR (Amount_Accrual IS NULL AND Amount_Charges IS NULL ) 
	
	--OR		Status != 3 
END

