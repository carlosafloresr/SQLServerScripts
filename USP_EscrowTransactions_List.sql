CREATE PROCEDURE USP_EscrowTransactions_List
	@CompanyId	Char(6), 
	@EscrowModule	Int,
	@Account	Char(15),
	@DateIni	SmallDateTime,
	@DateEnd	SmallDateTime
AS
USE AISTE

SELECT 	E1.*,
	ISNULL(P1.TrxDscrn, P2.TrxDscrn) AS TransDescription
FROM 	GPCustom.dbo.EscrowTransactions E1
	LEFT JOIN PM20000 P1 ON E1.VoucherNumber = P1.Vchrnmbr
	LEFT JOIN PM10000 P2 ON E1.VoucherNumber = P2.VchnumWk