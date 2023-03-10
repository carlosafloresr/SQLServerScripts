USE [CollectIT]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindInvoiceEquipmentId]    Script Date: 12/21/2016 8:38:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindInvoiceEquipmentId 1, 'AIS', '12-56825'
EXECUTE USP_FindInvoiceEquipmentId 'DNJ', '36-111722'
EXECUTE USP_FindInvoiceEquipmentId 'NDS', '5-103089_35'
*/
ALTER PROCEDURE [dbo].[USP_FindInvoiceEquipmentId]
	@Company	Varchar(5),
	@InvoiceNo	Varchar(20)
AS
SET NOCOUNT ON

EXECUTE ILSINT02.Integrations.dbo.USP_FSI_FindContainer @Company, @InvoiceNo
