CREATE VIEW View_MyTruckRecords
AS
SELECT	RM.CustNmbr
		,RM.DocNumbr
		,RM.DocDate
		,RM.OrTrxAmt
		,VM.VendorId
		,VM.Company
FROM	RCCL.dbo.RM30101 RM
		INNER JOIN VendorMaster VM ON RM.CustNmbr = VM.RCCLAccount AND VM.SubType = 2
UNION
SELECT	RM.CustNmbr
		,RM.DocNumbr
		,RM.DocDate
		,RM.OrTrxAmt
		,VM.VendorId
		,VM.Company
FROM	RCCL.dbo.RM20101 RM
		INNER JOIN VendorMaster VM ON RM.CustNmbr = VM.RCCLAccount AND VM.SubType = 2

-- select * from View_MyTruckRecords where company = 'AIS' AND DocDate = '4/23/2009'