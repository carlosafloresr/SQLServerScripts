USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_RapidPay_FileBound_DocCounter]    Script Date: 9/16/2022 8:55:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_RapidPay_FileBound_DocCounter @ProjectId=180, @Company='AIS', @VendorId='50010A', @Cancellation=0, @JustValidate=1
EXECUTE USP_RapidPay_FileBound_DocCounter @ProjectId=186, @Company='AIS', @VendorId='50010A', @Cancellation=0, @JustValidate=1
*/
ALTER PROCEDURE [dbo].[USP_RapidPay_FileBound_DocCounter] 
		@ProjectId		Int,
		@Company		Varchar(5),
		@VendorId		Varchar(15),
		@Cancellation	Bit = 0,
		@JustValidate	Bit = 0
WITH EXECUTE AS OWNER 
AS
SET NOCOUNT ON

DECLARE @URL			Varchar(150) = 'https://imagews.imcc.com/imaging-bs/v4/getImageCount',
		@Object			Int,
		@Counter		Int = 0,
		@LastSegment	Varchar(1000),
		@ResponseText	Varchar(8000),
		@CompanyAlias	Varchar(10) = (SELECT CompanyAlias FROM View_CompaniesAndAgents WHERE CompanyId = @Company),
		@Body			Varchar(8000),
		@DocType		Varchar(40) = IIF(@Cancellation = 0, 'ENROLLMENT FORM', 'CANCELATION FORM')

SET @ProjectId = 180
SET @Body = N'{
   "applicationId": ' + CAST(@ProjectId AS Varchar) + ',
   "OperatingCompany": "' + @CompanyAlias + '",
   "VendorID": "' + @VendorId + '",
   "documentCategory": "' + @DocType + '"
}'

--print @Body
EXECUTE sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
EXECUTE sp_OAMethod @Object, 'open', NULL, 'post', @URL, 'false'
EXECUTE sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
EXECUTE sp_OAMethod @Object, 'send', null, @body
EXECUTE sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT

IF RTRIM(@ResponseText) <> ''
BEGIN
	IF CHARINDEX('false',(SELECT @ResponseText)) = 0
	BEGIN
		DECLARE @JsonMain Varchar(MAX) = (SELECT @ResponseText)
		SELECT @LastSegment = Value FROM OPENJSON(@JsonMain) WHERE [Key] = 'imageDetails'
	
		DECLARE @JsonDetail Varchar(MAX) = (SELECT @LastSegment)
		SELECT @Counter = Value FROM OPENJSON(@JsonDetail)
	END
END

EXECUTE sp_OADestroy @Object

IF @JustValidate = 0
	UPDATE	GPVendorMaster 
	SET		RP_Documents = IIF(@Counter > 0, 1, 0)
	WHERE	Company = @Company
			AND VendorId = @VendorId
ELSE
	SELECT	@Counter AS FileBoundValid