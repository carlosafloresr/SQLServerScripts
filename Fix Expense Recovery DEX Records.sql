/*
EXECUTE USP_Fix_ExpenseRecovery_IntegrationAP
*/
ALTER PROCEDURE USP_Fix_ExpenseRecovery_IntegrationAP
AS
--UPDATE	ExpenseRecovery
--SET		EffDate		= DAT.PSTGDATE,
--		InvDate		= DAT.DOCDATE,
--		Closed		= 0,
--		Reference	= DAT.DISTREF,
--		Trailer		= DAT.Container,
--		Chassis		= DAT.Chassis
--FROM	(
--		SELECT	AP.VCHNUMWK
--				,AP.DOCDATE
--				,AP.PSTGDATE
--				,AP.DISTREF
--				,AP.PRONUM
--				,AP.CONTAINER
--				,AP.CHASSIS
--				,EX.ExpenseRecoveryId
--		FROM	ILSINT02.Integrations.dbo.Integrations_AP AP
--				INNER JOIN ExpenseRecovery EX ON AP.PopUpId = EX.PopUpId
--		WHERE	EX.EffDate < '1/1/1980'
--		) DAT
--WHERE	ExpenseRecovery.ExpenseRecoveryId = DAT.ExpenseRecoveryId
--GO

UPDATE	ExpenseRecovery
SET		EffDate		= DAT.PSTGDATE,
		InvDate		= DAT.DOCDATE,
		Closed		= 0,
		Reference	= DAT.DISTREF,
		Trailer		= DAT.Container,
		Chassis		= DAT.Chassis,
		Vendor		= DAT.Vendor
FROM	(
		SELECT	AP.VCHNUMWK
				,AP.Company
				,AP.DOCDATE
				,EX.VendorId
				,RTRIM(LEFT(RTRIM(LTRIM(AP.VendorId)) + ' - ' + dbo.GetVendorName(AP.Company, AP.VendorId), 30)) AS Vendor
				,AP.PSTGDATE
				,AP.DISTREF
				,AP.PRONUM
				,AP.CONTAINER
				,AP.CHASSIS
				,AP.PopUpId
				,EX.ExpenseRecoveryId
		FROM	ILSINT02.Integrations.dbo.Integrations_AP AP
				INNER JOIN (
							SELECT	SUBSTRING(EX.Vendor, 1, dbo.AT('-', EX.Vendor, 1) - 1) AS VendorId,
									EX.Vendor,
									DX.DEX_ER_PopUpsId,
									EX.ExpenseRecoveryId
							FROM	DEX_ER_PopUps DX
									INNER JOIN ExpenseRecovery EX ON DX.DEX_ER_PopUpsId = EX.PopUpId
							WHERE	EX.CreationDate > DATEADD(dd, -30, GETDATE())
									--AND EX.Closed = 0
							) EX ON AP.PopUpId = EX.DEX_ER_PopUpsId
		WHERE	(LEN(RTRIM(EX.Vendor)) < 10
				OR EX.VendorId <> AP.VendorId)
		) DAT
WHERE	ExpenseRecovery.ExpenseRecoveryId = DAT.ExpenseRecoveryId
		AND ExpenseRecovery.Vendor <> DAT.Vendor
GO