USE [GPCustom]
GO
/****** Object:  View [dbo].[View_MyTruckRecords]    Script Date: 05/08/2009 10:10:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_MyTruckRecords_Summary]
AS
SELECT	CustNmbr
		,VendorId
		,Company
		,SUM(CurTrxAm) AS CurTrxAm
FROM	(
		SELECT	RM.CustNmbr
				,RM.CurTrxAm * CASE WHEN RM.RmdTypal = 9 THEN -1 ELSE 1 END AS CurTrxAm
				,VM.VendorId
				,VM.Company
		FROM	RCCL.dbo.RM30101 RM
				INNER JOIN VendorMaster VM ON RM.CustNmbr = VM.RCCLAccount AND VM.SubType = 2
		UNION
		SELECT	RM.CustNmbr
				,RM.CurTrxAm * CASE WHEN RM.RmdTypal = 9 THEN -1 ELSE 1 END AS CurTrxAm
				,VM.VendorId
				,VM.Company
		FROM	RCCL.dbo.RM20101 RM
				INNER JOIN VendorMaster VM ON RM.CustNmbr = VM.RCCLAccount AND VM.SubType = 2) RECS
GROUP BY
		CustNmbr
		,VendorId
		,Company