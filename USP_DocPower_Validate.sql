USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_DocPower_Validate]    Script Date: 5/22/2019 8:47:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_DocPower_Validate '05/24/2019 05:00:00 AM'
*/
ALTER PROCEDURE [dbo].[USP_DocPower_Validate]
		@DateToCheck	Datetime = Null
AS
SET NOCOUNT ON

DECLARE	@RecordId		int,
		@Company		varchar(5),
		@CompanyNumber  smallint,
		@ProNumber		varchar(15),
		@DocumentType   varchar(15),
		@ToEmail		varchar(200),
		@FromUser		varchar(150),
		@EmailSubject   varchar(300),
		@AttachedFile   varchar(150),
		@ProcessedOn	datetime,
		@ProcessedBy	varchar(50),
		@IMAP_UId		bigint,
		@Success		bit,
		@Error			varchar(max),
		@InDocPower		bit,
		@Query			Varchar(1000),
		@Validated		smallint

DECLARE @tblImages		Table (DocType Varchar(5), UploadDate Date)

IF @DateToCheck IS Null
	SET @DateToCheck = GETDATE()

DECLARE curImagesMessages CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT [DocPowerImagesId]
      ,[Company]
      ,[CompanyNumber]
      ,[ProNumber]
      ,[DocumentType]
      ,[ToEmail]
      ,[FromUser]
      ,[EmailSubject]
      ,[AttachedFile]
      ,[ProcessedOn]
      ,[ProcessedBy]
      ,[IMAP_UId]
      ,[Success]
      ,[Error]
      ,[InDocPower]
      ,[Validated]
FROM	DocPowerImages
WHERE	Company <> ''
		AND Success = 1
		AND InDocPower = 0
		AND CompanyNumber IS NOT Null
		AND CAST(ProcessedOn AS Date) = CAST(@DateToCheck AS Date)
		AND Validated < 3

OPEN curImagesMessages 
FETCH FROM curImagesMessages INTO @RecordId, @Company, @CompanyNumber, @ProNumber, @DocumentType, @ToEmail,
										@FromUser, @EmailSubject, @AttachedFile, @ProcessedOn, @ProcessedBy,
										@IMAP_UId, @Success, @Error, @InDocPower, @Validated

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF LEFT(@ProNumber, 1) = '0'
		SET @ProNumber = SUBSTRING(@ProNumber, 2, 20)

	PRINT CAST(@CompanyNumber AS Varchar) + ' / ' + @ProNumber + ' / ' + @DocumentType
	
	DELETE @tblImages

	SET @Query = N'SELECT img.code, prod_scandt FROM proimgd p, com.doctype img WHERE prod_imgcat = img.imgcat AND appid = ''pro'' AND prod_company_id = ' + CAST(@CompanyNumber AS Varchar) + ' AND prod_load_no = ''' + RTRIM(@ProNumber) + ''''
	
	INSERT INTO @tblImages
	EXECUTE USP_QuerySWS @Query
	
	IF (SELECT COUNT(*) FROM @tblImages) > 0
	BEGIN
		IF EXISTS(SELECT DocType FROM @tblImages WHERE DocType = @DocumentType AND UploadDate >= CAST(@ProcessedOn AS Date))
		BEGIN
			UPDATE	DocPowerImages
			SET		InDocPower = 1,
					Validated = Validated + 1,
					Verified = 1
			WHERE	DocPowerImagesId = @RecordId
		END
		ELSE
		BEGIN
			UPDATE	DocPowerImages
			SET		Validated = Validated + 1,
					Verified = 1
			WHERE	DocPowerImagesId = @RecordId
		END
	END
	ELSE
	BEGIN
		UPDATE	DocPowerImages
		SET		Validated = Validated + 1,
				Verified = 1
		WHERE	DocPowerImagesId = @RecordId
	END

	FETCH FROM curImagesMessages INTO @RecordId, @Company, @CompanyNumber, @ProNumber, @DocumentType, @ToEmail,
										@FromUser, @EmailSubject, @AttachedFile, @ProcessedOn, @ProcessedBy,
										@IMAP_UId, @Success, @Error, @InDocPower, @Validated
END

CLOSE curImagesMessages
DEALLOCATE curImagesMessages