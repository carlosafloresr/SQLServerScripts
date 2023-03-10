USE [Tributary]
GO
/****** Object:  StoredProcedure [dbo].[USP_EBEImages]    Script Date: 9/20/2019 12:03:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
EXECUTE USP_EBEImages @LastDate = '12/31/2018', @JustCount = 1
EXECUTE USP_EBEImages @LastDate = '12/31/2018', @Records = 1
EXECUTE USP_EBEImages @LastDate = '12/31/2019', @Records = 10000, @Delete = 1
*/
ALTER PROCEDURE [dbo].[USP_EBEImages]
		@LastDate	Date,
		@Records	Int = 0,
		@JustCount	Bit = 0,
		@Delete		Bit = 0
AS
SET NOCOUNT ON

IF @JustCount = 1
BEGIN
	SELECT	COUNT(*)
	FROM	(
			SELECT	DISTINCT APP.Doc_ID
			FROM	PacketIDX_ShortPay PCK
					INNER JOIN App_Billing APP ON APP.InvoiceNumber = PCK.InvoiceNumber AND APP.CustomerID = PCK.CustomerId AND APP.Division = PCK.Division
					INNER JOIN [Page] PG ON APP.Doc_ID = PG.Doc_ID 
			WHERE	PCK.DatePaid <> ''
					AND APP.IndexDate <= @LastDate
			) DATA
END
ELSE
BEGIN
	DECLARE	@Server		Varchar(20) = IIF(@@SERVERNAME = 'LENSASQL001T', 'LENSAEBE001T', 'LENSAEBE001')
	DECLARE @tblData	Table (
			Company		Varchar(20),
			CustomerId	Varchar(30),
			InvoiceNo	Varchar(30),
			DocType		Varchar(20),
			FileDate	Date,
			[FileName]	Varchar(150),
			Doc_ID		Int)

	INSERT INTO @tblData
	SELECT	DISTINCT TOP (@Records) 
			LTRIM(ISNULL(APP.Division, 'UNKNO')) AS Company
			,LTRIM(APP.CustomerId) AS CustomerId
			,LTRIM(APP.InvoiceNumber) AS InvoiceNumber
			,APP.Doc_Type
			,CAST(APP.IndexDate AS Date) AS FileDate
			,'\\' + @Server + '\Images\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),1,1)+'\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),2,2)+'\'+SubString(RIGHT('0000000'+CAST(Page_ID as varchar),7),4,2)+'\'+CAST(Page_ID as varchar)+'.'+ft.Extension AS [Network Path]
			,APP.Doc_ID
	FROM	PacketIDX_ShortPay PCK
			INNER JOIN App_Billing APP ON APP.InvoiceNumber = PCK.InvoiceNumber AND APP.CustomerID = PCK.CustomerId AND APP.Division = PCK.Division
			INNER JOIN [Page] PG ON APP.Doc_ID = PG.Doc_ID 
			INNER JOIN [FileTypes] FT ON PG.FileTypeID = FT.MIMEID
	WHERE	PCK.DatePaid <> ''
			AND APP.IndexDate <= @LastDate
	ORDER BY 5

	IF @Delete = 1
	BEGIN
		DECLARE @Filehandle Int,
				@Doc_ID		Int,
				@FileName	Varchar(150)

		SELECT	*
		FROM	@tblData

		DECLARE curImages CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	DISTINCT [FileName], Doc_ID
		FROM	@tblData

		EXECUTE sp_OACreate 'Scripting.FileSystemObject', @Filehandle OUTPUT -- Create a file system object

		OPEN curImages 
		FETCH FROM curImages INTO @FileName, @Doc_ID

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			EXECUTE sp_OAMethod @Filehandle, 'DeleteFile', NULL, @FileName -- Delete file

			IF @@ERROR = 0
				EXECUTE USP_EBEDeleteImage @Doc_ID --, @FileName

			FETCH FROM curImages INTO @FileName, @Doc_ID
		END

		CLOSE curImages
		DEALLOCATE curImages		
		
		EXECUTE sp_OADestroy @Filehandle -- Memory cleanup
	END
	ELSE
		SELECT	*
		FROM	@tblData
END
