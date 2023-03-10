USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DocPowerImages]    Script Date: 5/31/2019 9:26:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[USP_DocPowerImages]
		@Company		varchar(5),
		@CompanyNumber	Smallint,
		@ProNumber		varchar(15),
		@DocumentType	varchar(15),
		@ToEmail		varchar(200),
		@FromUser		varchar(50),
		@EmailSubject	varchar(300),
		@EmailDate		datetime = Null,
		@AttachedFile	varchar(150) = Null,
		@ProcessedBy	varchar(50) = Null,
		@IMAP_UId		bigint = 0,
		@Success		bit = 0,
		@Error			Varchar(Max) =  Null
AS
DECLARE	@RecordId		Int,
		@Validated		Smallint = 0

SET @DocumentType = SUBSTRING(@EmailSubject, 1, dbo.AT(',', @EmailSubject, 1) - 1)

IF dbo.AT('[REPROCESS]', @EmailSubject, 1) > 0
	SET @RecordId = (SELECT TOP 1 DocPowerImagesId FROM dbo.DocPowerImages WHERE Company = @Company AND ProNumber = @ProNumber AND EmailSubject = @EmailSubject AND FromUser = @FromUser)

IF @RecordId IS Null
BEGIN
	IF dbo.AT('[REPROCESS]', @EmailSubject, 1) > 0
		SET @Validated = 2

	INSERT INTO dbo.DocPowerImages
			   (Company
			   ,CompanyNumber
			   ,ProNumber
			   ,DocumentType
			   ,ToEmail
			   ,FromUser
			   ,EmailSubject
			   ,EmailDate
			   ,AttachedFile
			   ,ProcessedBy
			   ,IMAP_UId
			   ,Success
			   ,Error
			   ,Validated)
		 VALUES
			   (@Company
			   ,@CompanyNumber
			   ,@ProNumber
			   ,@DocumentType
			   ,@ToEmail
			   ,@FromUser
			   ,@EmailSubject
			   ,@EmailDate
			   ,@AttachedFile
			   ,@ProcessedBy
			   ,@IMAP_UId
			   ,@Success
			   ,@Error
			   ,@Validated)
END
ELSE
BEGIN
	UPDATE	dbo.DocPowerImages
	SET		Validated	= Validated + 1,
			Error		= @Error,
			ProcessedOn = GETDATE()
	WHERE	DocPowerImagesId = @RecordId
END