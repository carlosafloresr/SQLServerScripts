ALTER VIEW View_DriverMaster
AS
SELECT	VMA.VendorId
		,GPCustom.dbo.GetVendorName(VMA.Company, VMA.VendorId) AS DriverName
		,VMA.Company
		,COM.CompanyName
		,COM.CompanyNumber
		,VMA.HireDate
		,VMA.TerminationDate
		,SDM.Dr_TermRem1 AS TerminationReason1
		,SDM.Dr_TermRem2 AS TerminationReason2
		,VMA.SubType
		,CASE WHEN VMA.SubType = 1 THEN 'OO' ELSE 'MYT' END AS DriverType
		,VMA.ApplyRate
		,VMA.Rate
		,VMA.ApplyAmount
		,VMA.Amount
		,VMA.ScheduledReleaseDate
		,SDM.Dr_Div_Code AS Division
		,VMA.CDL
		,VMA.RCCLAccount
		,VMA.Agent
		,VMA.ModifiedBy
		,VMA.ModifiedOn
		,VMA.UnitId
		,VMA.Miles
		,VMA.Issues
		,VMA.OldDriverId
		,CAST(CASE WHEN SDM.Dr_Rehire = 'N' THEN 0 ELSE 1 END AS Bit) AS Rehired
		,SDM.Dr_MyTruckDt AS MyTruckStartDate
		,SDM.Dr_Addr1 AS Address1
		,SDM.Dr_Addr2 AS Address2
		,SDM.Dr_City AS City
		,SDM.Dr_St_Code AS [State]
		,SDM.Dr_Zip AS ZipCode
		,SDM.Dr_Phone AS Phone
		,SDM.Dr_Mobile AS MobilePhone
		,SDM.Dr_SSN AS SSN
		,SDM.Dr_TMake AS Vehicle_Make
		,SDM.Dr_TYear AS Vehicle_Year
		,SDM.Dr_TVin AS Vehicle_VIN
		,SDM.Dr_TColor AS Vehicle_Color
		,SDM.Dr_TTag AS Vehicle_TAG
		,SDM.Dr_Race AS Race
FROM	GPCustom.dbo.VendorMaster VMA
		INNER JOIN GPCustom.dbo.Companies COM ON VMA.Company = COM.CompanyId
		LEFT JOIN ILSSQL01.Drivers.dbo.Sws_Drv_Mast SDM ON COM.CompanyNumber = SDM.Dr_Cmpy_No AND VMA.VendorId = SDM.Dr_Code

/*
SELECT * FROM View_DriverMaster WHERE Company = 'GIS' AND DriverType = 'MYT'
SELECT * FROM ILSSQL01.Drivers.dbo.Sws_Drv_Mast
*/