/****** Script for SelectTopNRows command from SSMS  ******/
SELECT	MR.MRInvoices_APId
		,MR.InvoiceNumber
		,FB.Field4 AS FB_Field4
		,MR.Field4
		,MR.Field5
		,MR.Field8
		,MR.Field9
		,MR.Field10 
		,MR.Field11
		,MR.Field13
		,MR.Field14
		,MR.Field16
		,MR.Field17
		,MR.Field18
		,MR.Field20
		,MR.CreatedOn
		,MR.UserId
		,MR.Accepted
		,MR.Integrated
		,MR.EIRI
		,MR.EIRI_ImageCreated
		,MR.DriverId
		,MR.DrvDivision
		,MR.DrvType
		,MR.EqOwner
		,MR.ModifiedOn
FROM	MRInvoices_AP MR
		LEFT JOIN PRIFBSQL01P.FB.dbo.View_DEXDocuments FB ON MR.Field8 = FB.Field8 AND MR.Field4 = FB.Field4 AND FB.ProjectID = 65
WHERE	MR.CreatedOn >= '01/13/2021'
		AND MR.Field20 < 51
ORDER BY MR.InvoiceNumber
