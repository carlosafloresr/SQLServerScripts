USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_RapidPay_FileBound_Validation]    Script Date: 1/28/2022 6:14:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RapidPay_FileBound_Validation 'GLSO', '1038'
*/
ALTER PROCEDURE [dbo].[USP_RapidPay_FileBound_Validation]
		@Company		Varchar(5),
		@VendorId		Varchar(15)
AS
SET NOCOUNT ON

DECLARE @ReturnValue	Bit = 0		
DECLARE @tblFileBound	Table (DocsCount Int)

INSERT INTO @tblFileBound
EXECUTE USP_RapidPay_FileBound_DocCounter 186, @Company, @VendorId

SELECT @ReturnValue = DocsCount FROM @tblFileBound

SELECT	ISNULL(@ReturnValue, 0) AS FileBoundValid