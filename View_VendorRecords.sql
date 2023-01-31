/*
SELECT * FROM PM20000 WHERE VchrNmbr = 'DPY4465090221_099    '
SELECT * FROM PM30200 WHERE VchrNmbr = 'DPY4465090221_099    '
SELECT * FROM PM30200 WHERE Division = '03' AND 
*/

USE PDS
GO

CREATE VIEW [dbo].[View_VendorRecords]
AS
SELECT	PMH.VendorId
		,VND.VendName
		,VND.Ten99Type
		,CASE	WHEN VND.Ten99Type IN (0,1) THEN 'No 1099'
				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
		 ELSE '1099 Miscellaneous' END AS Is1099
		,VND.VndClsId AS VendorType
		,PMH.VchrNmbr
		,TYP.DocTyNam
		,PMH.DocDate
		,PMH.DocNumbr
		,PMH.DocAmnt
		,PMH.CurTrxAm
		,PMH.Ten99Amnt AS Un1099AM
		,PMH.TrxDscrn
		,PAY.GLPostDT AS CheckDate
		,PAY.ApFrDcnm AS PayWithDocument
		,PAY.AppldAmt AS CheckAmount
		,COM.CmpnyNam AS CompanyName
		,COM.InterId AS CompanyId
		,RTRIM(COM.Address1) + CASE WHEN COM.Address2 IS Null OR RTRIM(COM.Address2) = '' THEN '' ELSE ' ' + RTRIM(COM.Address2) END + 
		CASE WHEN COM.City IS Null OR RTRIM(COM.City) = '' THEN '' ELSE CHAR(13) + RTRIM(COM.City) END +
		CASE WHEN COM.State IS Null OR RTRIM(COM.State) = '' THEN '' ELSE ', ' + RTRIM(COM.State) END +
		CASE WHEN COM.ZipCode IS Null OR RTRIM(COM.ZipCode) = '' THEN '' ELSE ' ' + RTRIM(COM.ZipCode) END AS Address
		,'GP' AS Source
		,6 AS DistType
		,PMH.DocAmnt AS DetailAmount
		,'' AS DistRef
		,CAST(YEAR(PAY.DocDate) AS Char(4)) + CASE WHEN MONTH(PAY.DocDate) < 10 THEN '0' + CAST(MONTH(PAY.DocDate) AS Char(1)) ELSE CAST(MONTH(PAY.DocDate) AS Char(4)) END AS SortDate
		,VMA.HireDate
		,VMA.TerminationDate
		,PMH.DocType
		,LastPayDate = (SELECT MAX(APL.DocDate) FROM PM30300 APL WHERE PMH.VendorId = APL.VendorId AND PMH.DocNumbr = APL.ApToDcnm)
		,PMH.Dex_Row_id
		,PMH.PstgDate AS PostEdDt
		,PAY.DocType AS PayType
		,VMA.Division
		,DIV.DivisionName
		,'PM20000' AS SourceTable
FROM	PM20000 PMH
		INNER JOIN PM10200 PAY ON PMH.VendorId = PAY.VendorId AND PMH.DocNumbr = PAY.ApToDcnm
		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
		INNER JOIN PM40102 TYP ON PMH.DocType = TYP.DocType
		INNER JOIN Dynamics.dbo.View_AllCompanies COM ON COM.InterId = DB_NAME()
		LEFT JOIN GPCustom.dbo.VendorMaster VMA ON PMH.VendorId = VMA.VendorId AND VMA.Company = COM.InterId
		LEFT JOIN GPCustom.dbo.View_Divisions DIV ON VMA.Division = DIV.Division AND DIV.Fk_CompanyId = VMA.Company
WHERE	PMH.BCHSOURC IN ('XPM_Cchecks','PM_Trxent','XXPM_Trxent')
UNION
SELECT	PMH.VendorId
		,VND.VendName
		,VND.Ten99Type
		,CASE	WHEN VND.Ten99Type IN (0,1) THEN 'No 1099'
				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
		 ELSE '1099 Miscellaneous' END AS Is1099
		,VND.VndClsId AS VendorType
		,PMH.VchrNmbr
		,TYP.DocTyNam
		,PMH.DocDate
		,PMH.DocNumbr
		,PMH.DocAmnt
		,PMH.CurTrxAm
		,PMH.Ten99Amnt AS Un1099AM
		,PMH.TrxDscrn
		,PAY.GLPostDT AS CheckDate
		,PAY.ApFrDcnm AS PayWithDocument
		,PAY.AppldAmt AS CheckAmount
		,COM.CmpnyNam AS CompanyName
		,COM.InterId AS CompanyId
		,RTRIM(COM.Address1) + CASE WHEN COM.Address2 IS Null OR RTRIM(COM.Address2) = '' THEN '' ELSE ' ' + RTRIM(COM.Address2) END + 
		CASE WHEN COM.City IS Null OR RTRIM(COM.City) = '' THEN '' ELSE CHAR(13) + RTRIM(COM.City) END +
		CASE WHEN COM.State IS Null OR RTRIM(COM.State) = '' THEN '' ELSE ', ' + RTRIM(COM.State) END +
		CASE WHEN COM.ZipCode IS Null OR RTRIM(COM.ZipCode) = '' THEN '' ELSE ' ' + RTRIM(COM.ZipCode) END AS Address
		,'GP' AS Source
		,6 AS DistType
		,PMH.DocAmnt AS DetailAmount
		,'' AS DistRef
		,CAST(YEAR(PAY.DocDate) AS Char(4)) + CASE WHEN MONTH(PAY.DocDate) < 10 THEN '0' + CAST(MONTH(PAY.DocDate) AS Char(1)) ELSE CAST(MONTH(PAY.DocDate) AS Char(4)) END AS SortDate
		,VMA.HireDate
		,VMA.TerminationDate
		,PMH.DocType
		,LastPayDate = (SELECT MAX(APL.DocDate) FROM PM30300 APL WHERE PMH.VendorId = APL.VendorId AND PMH.DocNumbr = APL.ApToDcnm)
		,PMH.Dex_Row_id
		,PMH.PstgDate AS PostEdDt
		,PAY.DocType AS PayType
		,VMA.Division
		,DIV.DivisionName
		,'PM30200' AS SourceTable
FROM	PM30200 PMH
		INNER JOIN PM30300 PAY ON PMH.VendorId = PAY.VendorId AND PMH.DocNumbr = PAY.ApToDcnm --AND PAY.DocType = 6
		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
		INNER JOIN PM40102 TYP ON PMH.DocType = TYP.DocType
		INNER JOIN Dynamics.dbo.View_AllCompanies COM ON COM.InterId = DB_NAME()
		LEFT JOIN GPCustom.dbo.VendorMaster VMA ON PMH.VendorId = VMA.VendorId AND VMA.Company = COM.InterId
		LEFT JOIN GPCustom.dbo.View_Divisions DIV ON VMA.Division = DIV.Division AND DIV.Fk_CompanyId = VMA.Company
WHERE	PMH.BCHSOURC IN ('XPM_Cchecks','PM_Trxent','XXPM_Trxent')
GO
--UNION
--SELECT	PMH.VendorId
--		,VND.VendName
--		,VND.Ten99Type
--		,CASE	WHEN VND.Ten99Type IN (0,1) THEN 'No 1099'
--				WHEN VND.Ten99Type = 2 THEN '1099 Dividend'
--				WHEN VND.Ten99Type = 3 THEN '1099 Interest'
--		 ELSE '1099 Miscellaneous' END AS Is1099
--		,VND.VndClsId AS VendorType
--		,PMH.VchrNmbr
--		,'Invoice'
--		,Null
--		,PMH.DocNumbr
--		,PMH.DocAmnt + PMH.Ten99Amnt
--		,0
--		,PMH.Ten99Amnt
--		,PMH.TrxDscrn
--		,PMH.CheckDate
--		,PMH.CheckNo
--		,PMH.CheckAmount
--		,COM.CmpnyNam AS CompanyName
--		,COM.InterId AS CompanyId
--		,RTRIM(COM.Address1) + CASE WHEN COM.Address2 IS Null OR RTRIM(COM.Address2) = '' THEN '' ELSE ' ' + RTRIM(COM.Address2) END + 
--		CASE WHEN COM.City IS Null OR RTRIM(COM.City) = '' THEN '' ELSE CHAR(13) + RTRIM(COM.City) END +
--		CASE WHEN COM.State IS Null OR RTRIM(COM.State) = '' THEN '' ELSE ', ' + RTRIM(COM.State) END +
--		CASE WHEN COM.ZipCode IS Null OR RTRIM(COM.ZipCode) = '' THEN '' ELSE ' ' + RTRIM(COM.ZipCode) END AS Address
--		,'APPGEN' AS Source
--		,Null
--		,PMH.DocAmnt + PMH.Ten99Amnt
--		,Null
--		,Null
--		,VMA.HireDate
--		,VMA.TerminationDate
--		,1
--		,PMH.CheckDate
--		,Null
--		,Null
--		,6
--		,VMA.Division
--		,DIV.DivisionName
--		,'AppgenData' AS SourceTable
--FROM	GPCustom.dbo.AppgenData PMH
--		INNER JOIN PM00200 VND ON PMH.VendorId = VND.VendorId
--		INNER JOIN Dynamics.dbo.View_AllCompanies COM ON COM.InterId = DB_NAME()
--		LEFT JOIN GPCustom.dbo.VendorMaster VMA ON PMH.VendorId = VMA.VendorId AND VMA.Company = DB_NAME()
--		LEFT JOIN GPCustom.dbo.View_Divisions DIV ON VMA.Division = DIV.Division AND DIV.Fk_CompanyId = VMA.Company
--WHERE	PMH.Company = DB_NAME()