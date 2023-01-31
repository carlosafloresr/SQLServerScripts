/*
select * from CustomerMaster where custnmbr in ('6078','6079','6080','6081','6084','1881')

update CustomerMaster set changed=1, trasmitted=0 where custnmbr in ('6078','6079','6080','6081','6084','1881')
update CustomerMaster set changed=1, trasmitted=0 where hold = 1
*/

INSERT INTO CustomerMaster
	   (CompanyId,
		CustNmbr,
		CustName,
		CustClas,
		Address1,
		Address2,
		City,
		State,
		Zip,
		Phone1,
		Inactive,
		Hold,
		CntCprsn,
		Changed,
		Trasmitted,
		ChangedBy,
		Result)
SELECT	'AIS',
		CustNmbr,
		CustName,
		CustClas,
		Address1,
		Address2,
		City,
		State,
		Zip,
		Phone1,
		Inactive,
		Hold,
		CntCprsn,
		CAST(1 AS Bit) AS Changed,
		CAST(0 AS Bit) AS Trasmitted,
		'' AS ChangedBy,
		'' AS Result
FROM	ais.dbo.RM00101 
WHERE	CustNmbr NOT IN (SELECT CustNmbr FROM CustomerMaster) AND
		CustName <> ''

UPDATE	CustomerMaster
SET		CustNmbr = RM.CustNmbr,
		CustName = RM.CustName,
		CustClas = RM.CustClas,
		Address1 = RM.Address1,
		Address2 = RM.Address2,
		City = RM.City,
		State = RM.State,
		Zip = RM.Zip,
		Phone1 = RM.Phone1,
		Inactive = RM.Inactive,
		Hold = RM.Hold,
		CntCprsn = RM.CntCprsn,
		Changed = 1,
		Trasmitted = 0
FROM	AIS.dbo.RM00101 RM
WHERE	CustomerMaster.CustNmbr = RM.CustNmbr AND
		CustomerMaster.Inactive <> RM.Inactive

-- select * from ais.dbo.RM00101 where CustNmbr = '6078'