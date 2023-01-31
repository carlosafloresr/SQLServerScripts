DECLARE	@ModuleId		Varchar(5) = 'KIM', 
		@Level			Int = 2, 
		@UserId			Varchar(25) = 'CFLORES'

DECLARE	@MinAmount		Numeric(12,2),
		@MaxAmount		Numeric(12,2),
		@ParLevel		Numeric(12,2),
		@MaxLevel1		Numeric(12,2),
		@Overwriters	Varchar(Max),
		@SpecialUser	Bit,
		@InvNoIni		Int,
		@IncNoEnd		Int

SET		@Overwriters	= UPPER(dbo.ReadParameter_Memo('KAR_ACCTUSERS', 'ALL'))
SET		@SpecialUser	= CASE WHEN PATINDEX('%' + RTRIM(@UserId) + '%', @Overwriters) > 0 THEN 1 ELSE 0 END
SET		@MinAmount		= 0.01
SET		@MaxAmount		= 999999999
SET		@MaxLevel1		= (SELECT MaxAmount FROM WorkFlowApprovalLevels WHERE ModuleId = @ModuleId AND ApprovalLevel = 1)

IF @Level = 0
	SET @MinAmount = 0
	
IF @Level = 2
	SET @MinAmount = @MinAmount + @MaxLevel1
PRINT 1
PRINT GETDATE()

SELECT	@IncNoEnd = MAX(InvoiceNumber),
		@InvNoIni = MIN(InvoiceNumber)
FROM	View_KarmakIntegration
WHERE	BatchId = 'SLSWE070117'
		AND CustomerNumber NOT IN ('AIS','GIS','RCMR')
		AND InvoiceTotal > 0


SELECT	*
INTO	##tmpSalesOrders
FROM	[LENSAKMK001\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders
WHERE	InvoiceNumber BETWEEN @InvNoIni AND @IncNoEnd

SELECT	RECS.RecordType
		,RECS.RecordId
		,RECS.ApprovalLevel
		,RECS.ApprovalLevelInvoice
		,RECS.InvoiceTotal
		,RECS.Priority
		,RECS.RecordId AS ApprovedRecord
		,RECS.ApprovedOn
		,RECS.KarmakIntegrationId
		,RECS.ForApproval
		,RECS.Approver
		,RECS.Approved
		,RECS.RecordApproved
		,ISNULL(RECS.Notes, LastNotes) AS Notes
INTO	#TempApprovals
FROM	(
		SELECT	WFA.RecordType
				,WFA.RecordId
				,WFA.ApprovalLevel
				,WFL.ApprovalLevel AS ApprovalLevelInvoice
				,WFA.Priority
				,API.RecordId AS ApprovedRecord
				,API.ApprovedOn
				,KAR.KarmakIntegrationId
				,CASE	WHEN WFA.RecordType = 'U' AND WFA.RecordId = @UserId AND API.RecordId IS Null AND (KAR.Approved IS Null OR KAR.Approved = 0) THEN 1
						WHEN WFA.RecordType = 'U' AND WFA.RecordId <> @UserId THEN 0
						ELSE CASE WHEN GPCustom.dbo.IsUserInGroup(@UserId, WFA.RecordId) = 1 AND (KAR.Approved IS Null OR KAR.Approved = 1) THEN 1 ELSE 0 END END AS ForApproval
				,CASE	WHEN WFA.RecordType = 'U' AND WFA.RecordId = @UserId THEN @UserId
						WHEN WFA.RecordType = 'U' AND WFA.RecordId <> @UserId THEN WFA.RecordId
						WHEN GPCustom.dbo.IsUserInGroup(@UserId, WFA.RecordId) = 1 THEN @UserId
						WHEN GPCustom.dbo.IsUserInGroup(@UserId, WFA.RecordId) = 0 THEN 'NONE' END AS Approver
				,KAR.Approved
				,API.ApprovedRecord AS RecordApproved
				,API.Notes
				,Null AS LastNotes --(SELECT TOP 1 Notes FROM WorkFlowApprovedItems WFAI WHERE WFAI.ModuleId = WFA.ModuleId AND WFAI.RecordId = KAR.KarmakIntegrationId ORDER BY WFAI.WorkFlowApprovedItemId DESC)
				,API.RecordId AS TestId
				,KAR.InvoiceTotal
		FROM	View_KarmakIntegration KAR
				INNER JOIN View_WorkFlowApprovalLevels WFL ON KAR.InvoiceTotal BETWEEN WFL.MinAmount AND WFL.MaxAmount AND WFL.ModuleId = @ModuleId
				LEFT JOIN WorkFlowApprovals WFA ON WFL.ApprovalLevel = WFA.ApprovalLevel AND WFL.ModuleId = WFA.ModuleId AND WFA.Approver = 1
				LEFT JOIN WorkFlowApprovedItems API ON API.ModuleId = @ModuleId AND KAR.KarmakIntegrationId = API.RecordId AND WFA.WorkFlowApprovalId = API.Fk_ApproverId
		WHERE	KAR.Processed = 2
				AND KAR.CustomerNumber NOT IN ('AIS','GIS','RCMR') 
				AND KAR.InvoiceTotal BETWEEN @MinAmount AND @MaxAmount) RECS
ORDER BY KarmakIntegrationId, Priority
PRINT 2
PRINT GETDATE()
SELECT	BatchId
		,'IMC' AS Company
		,KAR.WeekEndDate
		,KAR.InvoiceNumber
		,KAR.InvoicedDate
		,KAR.CustomerNumber
		,KAR.UnitNumber
		,KAR.Labor
		,KAR.Fuel_Price
		,KAR.Tires_Price
		,KAR.Misc_Price
		,KAR.Parts_Price
		,KAR.Shop_Price
		,Fees_Price = (CASE WHEN KAR.Misc_Price + KAR.Tires_Price + KAR.Shop_Price + KAR.Fuel_Price <> 0 THEN 0 ELSE (SELECT Fees_Price_All FROM ##tmpSalesOrders SAL WHERE SAL.InvoiceNumber = KAR.InvoiceNumber) END)
		,KAR.OrderTax
		,KAR.InvoiceTotal
		,KAR.Total
		,ISNULL(KAR.Division, TRK.Division) AS Division
		,KAR.Processed
		,ISNULL(KAR.Approved, 0) AS Approved
		,FAP.Approver
		,CASE WHEN (KAR.Approved IS Null OR KAR.Approved = 0) AND (FAP.Approver = @UserId OR @SpecialUser = 1) AND TRK.UnitNumber IS NOT Null THEN 1 ELSE 0 END AS ForApproval
		,KAR.KarmakIntegrationId
		,CASE WHEN TRK.UnitNumber IS NOT Null THEN 'COM' ELSE CASE WHEN MYTR.UnitId IS Null THEN 'OOP' ELSE CASE WHEN LEFT('TEST', 1) = 'S' THEN 'SAF' ELSE 'MYT' END END END AS TruckType --KSO.ServiceTypes
		,CASE WHEN KAR.Approved IS Null THEN Null ELSE FAP.Notes END AS Notes
		,CASE WHEN KAR.Approved IS Null AND FAP.Approver = @UserId THEN 0 ELSE @SpecialUser END AS SpecialUser
		,KSO.IsClaim
		,KSO.ServiceTypes
		,KSO.NumberOfServices
		,KAR.Account1
		,KAR.Amount1
		,KAR.Description1
		,KAR.Account2
		,KAR.Amount2
		,KAR.Description2
		,KAR.Account3
		,KAR.Amount3
		,KAR.Description3
		,KSO.AmntMR
		,KSO.AmntTires
		,KSO.AmntPeopleNet
		,KSO.DescMR
		,KSO.DescTires
		,KSO.DescPeopleNet
		,KAR.AcctApproved
		,KAR.PopUp
INTO	#TempKarmak
FROM	View_KarmakIntegration KAR
		INNER JOIN ##tmpSalesOrders KSO ON KAR.InvoiceNumber = KSO.InvoiceNumber
		INNER JOIN View_WorkFlowApprovalLevels WFA ON KAR.InvoiceTotal BETWEEN WFA.MinAmount AND WFA.MaxAmount AND WFA.ModuleId = 'KIM'
		LEFT JOIN (SELECT	KarmakIntegrationId
							,COUNT(KarmakIntegrationId) AS TotApprovers
							,SUM(CASE WHEN ApprovedRecord IS NULL THEN 0 ELSE 1 END) AS Approved
							,MIN(Priority) AS Priority
					FROM	#TempApprovals
					WHERE	RecordApproved IS NULL
					GROUP BY KarmakIntegrationId) APR ON KAR.KarmakIntegrationId = APR.KarmakIntegrationId
		LEFT JOIN ( SELECT	KarmakIntegrationId
							,Approver
							,ForApproval
							,Priority
							,Notes
					FROM	#TempApprovals
					WHERE	Approver = @UserId) FAP ON KAR.KarmakIntegrationId = FAP.KarmakIntegrationId AND APR.Priority = FAP.Priority
		LEFT JOIN ILSSQL01.Drivers.dbo.Trucks TRK ON KAR.TruckNumber = TRK.UnitNumber
		LEFT JOIN (SELECT RTRIM(UnitId) AS UnitId FROM VendorMaster WHERE SubType = 2 AND UnitId IS NOT Null AND UnitId <> '') MYTR ON KAR.TruckNumber = MYTR.UnitId
WHERE	KAR.Processed = 2
		AND KAR.CustomerNumber NOT IN ('AIS','GIS','RCMR') 
		AND KAR.InvoiceTotal BETWEEN @MinAmount AND @MaxAmount
ORDER BY KAR.InvoiceNumber
PRINT 3
PRINT GETDATE()
SELECT	BatchId
		,Company
		,WeekEndDate
		,InvoiceNumber
		,InvoicedDate
		,CustomerNumber
		,UnitNumber
		,Labor
		,Fuel_Price
		,Tires_Price
		,Misc_Price
		,Parts_Price
		,Shop_Price
		,Fees_Price
		,OrderTax
		,InvoiceTotal
		,Total
		,Division
		,Processed
		,Approved
		,Approver
		,ForApproval
		,KarmakIntegrationId
		,TruckType
		,Notes
		,SpecialUser
		,IsClaim
		,ServiceTypes
		,NumberOfServices
		,Account1
		,Amount1
		,Description1
		,Account2
		,CASE WHEN NumberOfServices = 2 THEN Amount2 - ((Amount1 + Amount2) - InvoiceTotal) ELSE Amount2 END AS Amount2
		,Description2
		,Account3
		,CASE WHEN NumberOfServices = 3 THEN Amount3 - ((Amount1 + Amount2 + Amount3) - InvoiceTotal) ELSE Amount3 END AS Amount3
		,Description3
		,AcctApproved
		,PopUp
INTO	#TempFinalKarmak
FROM	(SELECT	TKA.BatchId
				,TKA.Company
				,TKA.WeekEndDate
				,TKA.InvoiceNumber
				,TKA.InvoicedDate
				,TKA.CustomerNumber
				,TKA.UnitNumber
				,TKA.Labor
				,TKA.Fuel_Price
				,TKA.Tires_Price
				,TKA.Misc_Price
				,TKA.Parts_Price
				,TKA.Shop_Price
				,TKA.Fees_Price
				,TKA.OrderTax
				,TKA.InvoiceTotal
				,TKA.Total
				,TKA.Division
				,TKA.Processed
				,TKA.Approved
				,TKA.Approver
				,TKA.ForApproval
				,TKA.KarmakIntegrationId
				,TKA.TruckType
				,TKA.Notes
				,TKA.SpecialUser
				,TKA.IsClaim
				,TKA.ServiceTypes
				,TKA.NumberOfServices
				,CASE WHEN TKA.Account1 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD')) END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD')) END
						END
					ELSE
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN ServiceTypes = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN ServiceTypes = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE Null END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 1, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 1, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE Null END
						END
					END
				ELSE TKA.Account1 END AS Account1
				,CASE WHEN TKA.Amount1 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN AmntMR - (AmntMR - InvoiceTotal) ELSE AmntTires - (AmntTires - InvoiceTotal) END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN AmntMR - (AmntMR - InvoiceTotal) ELSE AmntTires - (AmntTires - InvoiceTotal) END
						END
					ELSE
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN AmntMR - (AmntMR - InvoiceTotal)
								  WHEN ServiceTypes = 'T' THEN AmntTires - (AmntTires - InvoiceTotal)
							 ELSE AmntPeopleNet - (AmntPeopleNet - InvoiceTotal) END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN AmntMR
								  WHEN SUBSTRING(ServiceTypes, 1, 1) = 'T' THEN AmntTires
							 ELSE AmntPeopleNet END
						END
					END
				ELSE TKA.Amount1 END AS Amount1
				,CASE WHEN TKA.Description1 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN DescMR ELSE DescTires END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN DescMR ELSE DescTires END
						END
					ELSE
						CASE WHEN NumberOfServices = 1 THEN
							 CASE WHEN ServiceTypes = 'M' THEN DescMR
								  WHEN ServiceTypes = 'T' THEN DescTires
							 ELSE DescPeopleNet END
						ELSE
							 CASE WHEN SUBSTRING(ServiceTypes, 1, 1) = 'M' THEN DescMR
								  WHEN SUBSTRING(ServiceTypes, 1, 1) = 'T' THEN DescTires
							 ELSE DescPeopleNet END
						END
					END
				ELSE TKA.Description1 END AS Description1
				,CASE WHEN TKA.Account2 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD')) END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE Null END
						ELSE
							CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								 WHEN SUBSTRING(ServiceTypes, 3, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								 WHEN SUBSTRING(ServiceTypes, 3, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							ELSE Null END
						END
					END
				ELSE TKA.Account2 END AS Account2
				,CASE WHEN TKA.Amount2 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN AmntMR - (AmntMR - InvoiceTotal) ELSE AmntTires - (AmntTires - InvoiceTotal) END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN AmntMR - (AmntMR - InvoiceTotal)
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'T' THEN AmntTires - (AmntTires - InvoiceTotal)
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'P' THEN AmntPeopleNet - (AmntPeopleNet - InvoiceTotal)
							 ELSE Null END
						ELSE Null END
					END
				ELSE TKA.Amount2 END AS Amount2
				,CASE WHEN TKA.Description2 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN DescMR ELSE DescTires END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 2 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN DescMR
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'T' THEN DescTires
								  WHEN SUBSTRING(ServiceTypes, 2, 1) = 'P' THEN DescPeopleNet
							 ELSE Null END
						ELSE Null END
					END
				ELSE TKA.Description2 END AS Description2
				,CASE WHEN TKA.Account3 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 2, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD')) END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN REPLACE((SELECT KAC.AcctMaintRep FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'T' THEN REPLACE((SELECT KAC.AcctTires FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'P' THEN REPLACE((SELECT KAC.AcctPeopleNet FROM KarmakAccounts KAC WHERE KAC.AccountType = TKA.TruckType), 'DD', ISNULL(TKA.Division, 'DD'))
							 ELSE Null END
						ELSE Null END
					END
				ELSE TKA.Account3 END AS Account3
				,CASE WHEN TKA.Amount3 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN AmntMR - (AmntMR - InvoiceTotal) ELSE AmntTires - (AmntTires - InvoiceTotal) END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN AmntMR - (AmntMR - InvoiceTotal)
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'T' THEN AmntTires - (AmntTires - InvoiceTotal)
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'P' THEN AmntPeopleNet - (AmntPeopleNet - InvoiceTotal)
							 ELSE Null END
						ELSE Null END
					END
				ELSE TKA.Amount3 END AS Amount3
				,CASE WHEN TKA.Description3 IS Null THEN
					CASE WHEN IsClaim = 1 THEN
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN DescMR ELSE DescTires END
						ELSE Null END
					ELSE
						CASE WHEN NumberOfServices = 3 THEN
							 CASE WHEN SUBSTRING(ServiceTypes, 3, 1) = 'M' THEN DescMR
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'T' THEN DescTires
								  WHEN SUBSTRING(ServiceTypes, 3, 1) = 'P' THEN DescPeopleNet
							 ELSE Null END
						ELSE Null END
					END
				ELSE TKA.Description3 END AS Description3
				,TKA.AcctApproved
				,PopUp
		FROM	#TempKarmak TKA
		WHERE	(@Level = 2 AND TKA.TruckType = 'COM')
				OR (@Level = 1 AND TKA.TruckType <> '999')
				OR (@Level = 0 AND TKA.InvoiceTotal <> 0)) RECS
PRINT 4
PRINT GETDATE()
SELECT	DISTINCT BatchId
		,Company
		,WeekEndDate
		,InvoiceNumber
		,InvoicedDate
		,CustomerNumber
		,UnitNumber
		,Labor
		,Fuel_Price
		,Tires_Price
		,Misc_Price
		,Parts_Price
		,Shop_Price
		,Fees_Price
		,OrderTax
		,InvoiceTotal
		,Total
		,Division
		,Processed
		,Approved
		,Approver
		,ForApproval
		,KarmakIntegrationId
		,TruckType
		,Notes
		,SpecialUser
		,IsClaim
		,ServiceTypes
		,NumberOfServices
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Account2 ELSE Account1 END AS Account1
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Amount2 ELSE Amount1 END AS Amount1
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Description2 ELSE Description1 END AS Description1
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Null ELSE Account2 END AS Account2
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Null ELSE Amount2 END AS Amount2
		,CASE WHEN Amount1 = 0 AND Amount2 > 0 THEN Null ELSE Description2 END AS Description2
		,Account3
		,Amount3
		,Description3
		,CASE WHEN NumberOfServices > 1 THEN 'Multi-' + RTRIM(ServiceTypes) ELSE
			  CASE WHEN RTRIM(ServiceTypes) = 'M' THEN'M&R'
				   WHEN RTRIM(ServiceTypes) = 'T' THEN'Tires'
			  ELSE 'PeopleNet' END END AS Category
		,AcctApproved
		,PopUp = CASE WHEN dbo.IsPopUpAccount('IMC',Account1) = 1 OR dbo.IsPopUpAccount('IMC',Account2) = 1 OR dbo.IsPopUpAccount('IMC',Account3) = 1 THEN 1 ELSE 0 END
INTO	#TempFinalKarmak2
FROM	#TempFinalKarmak

UPDATE	KarmakIntegration
SET		KarmakIntegration.Account1 = #TempFinalKarmak2.Account1,
		KarmakIntegration.Amount1 = #TempFinalKarmak2.Amount1,
		KarmakIntegration.Description1 = #TempFinalKarmak2.Description1,
		KarmakIntegration.Account2 = #TempFinalKarmak2.Account2,
		KarmakIntegration.Amount2 = #TempFinalKarmak2.Amount2,
		KarmakIntegration.Description2 = #TempFinalKarmak2.Description2,
		KarmakIntegration.Account3 = #TempFinalKarmak2.Account3,
		KarmakIntegration.Amount3 = #TempFinalKarmak2.Amount3,
		KarmakIntegration.Description3 = #TempFinalKarmak2.Description3,
		KarmakIntegration.Division = #TempFinalKarmak2.Division,
		KarmakIntegration.Category = #TempFinalKarmak2.Category,
		KarmakIntegration.NumberOfServices = #TempFinalKarmak2.NumberOfServices,
		KarmakIntegration.TruckType = #TempFinalKarmak2.TruckType,
		KarmakIntegration.ServiceTypes = #TempFinalKarmak2.ServiceTypes,
		KarmakIntegration.IsClaim = #TempFinalKarmak2.IsClaim,
		KarmakIntegration.Approved = CASE WHEN #TempFinalKarmak2.InvoiceTotal <= @MaxLevel1 THEN 1 ELSE #TempFinalKarmak2.Approved END
FROM	#TempFinalKarmak2
WHERE	KarmakIntegration.InvoiceNumber = #TempFinalKarmak2.InvoiceNumber
--		--AND ((@Level = 2 AND KarmakIntegration.InvoiceTotal > @MaxLevel1) OR (@Level <> 2 AND KarmakIntegration.InvoiceTotal > 0))
		
SELECT DISTINCT * FROM #TempFinalKarmak2 --WHERE ((@Level = 2 AND InvoiceTotal > @MaxLevel1) OR (@Level <> 2 AND InvoiceTotal > 0))

DROP TABLE #TempApprovals
DROP TABLE #TempKarmak
DROP TABLE #TempFinalKarmak
DROP TABLE #TempFinalKarmak2
DROP TABLE ##tmpSalesOrders