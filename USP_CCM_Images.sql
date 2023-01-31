/*
EXECUTE USP_CCM_Images '815171'
*/
ALTER PROCEDURE USP_CCM_Images
		@InvNo	Varchar(12)
AS
SELECT	REP.WorkOrder
		,REP.InvoiceNumber
		,REP.EquipmentType
		,PIC.PictureFileName
		,RTRIM(PAR.VarC) + RTRIM(REP.InvoiceNumber) + '_' + dbo.PADL(ROW_NUMBER() OVER(ORDER BY REP.EquipmentType), 2, '0')  + '_' + CASE WHEN REP.EquipmentType = 'C' THEN 'a' ELSE 'b' END + '.jpg' AS CCM_Image
FROM	Repairs REP
		INNER JOIN CCM_Customers CCM ON REP.CustomerNumber = CCM.CustomerNumber
		INNER JOIN RepairsPictures PIC ON REP.RepairId = PIC.Fk_RepairId
		INNER JOIN Integrations.dbo.Parameters PAR ON PAR.Company = 'ALL' AND PAR.ParameterCode = 'FIDEPOTIMAGES'
WHERE	REP.InvoiceNumber = @InvNo
		AND PIC.PictureFileName NOT LIKE '%SIGNA%'
ORDER BY REP.InvoiceNumber, REP.EquipmentType