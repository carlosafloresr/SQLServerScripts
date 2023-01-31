INSERT INTO GPCustom.dbo.Purchasing_Vouchers
           (Source
           ,VoucherNumber
           ,CompanyId
           ,ProNumber
           ,TrailerNumber
           ,ChassisNumber
           ,DriverId
           ,BatchId
           ,EnteredBy
           ,EnteredOn
           ,ChangedBy
           ,ChangedOn) 
SELECT	ESC.Source
		,PVO.VoucherNumber
		,PVO.CompanyId 
		,PVO.ProNumber
		,PVO.TrailerNumber
		,PVO.ChassisNumber
		,PVO.DriverId
		,PVO.BatchId
		,PVO.EnteredBy
		,PVO.EnteredOn
		,PVO.ChangedBy
		,PVO.ChangedOn
FROM	View_EscrowTransactions ESC
		INNER JOIN Purchasing_Vouchers PVO ON ESC.VoucherNumber = PVO.VoucherNumber AND ESC.CompanyId = PVO.CompanyId --AND ESC.Source = PVO.Source
WHERE	AccountNumber IN ('0-00-1102','0-00-1103','0-00-1104','0-00-1105')
		AND ESC.Source <> PVO.Source
		AND ESC.ProNumber IS Null