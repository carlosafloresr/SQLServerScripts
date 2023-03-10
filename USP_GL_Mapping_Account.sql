USE [Manifest_Test]
GO
/****** Object:  StoredProcedure [dbo].[USP_GL_Mapping_Account]    Script Date: 5/30/2017 11:58:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_GL_Mapping_Account 'SWSIGS', '357'
*/
CREATE PROCEDURE [dbo].[USP_GL_Mapping_Account]
		@Company		Varchar(10),
		@ChargeCode		Varchar(5)
AS
SELECT	[company]
		,[charge_code]
		,[charge_description]
		,[ap_code]
FROM	[Manifest_Test].[dbo].[GL_Mapping]
WHERE	Company = @Company
		AND charge_code = @ChargeCode
