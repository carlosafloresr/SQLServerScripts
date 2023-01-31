CREATE VIEW View_CustomerPerDiem
AS
SELECT	CUMA.CompanyId,
		CUMA.CustNmbr,
		CUMA.CustName,
		CUMA.BillType,
		CUMA.SCAC_Code,
		CUMA.FreightBillTo,
		PRPE.LPCode,
		PRPE.PDBillTo,
		PRPE.PrincipalPerDiemId,
		PRPE.Tariff
FROM	CustomerMaster CUMA
		LEFT JOIN PrincipalPerDiem PRPE ON CUMA.CompanyId = PRPE.CompanyId AND CUMA.CustNmbr = PRPE.CustNmbr
WHERE	CUMA.BillType <> 0