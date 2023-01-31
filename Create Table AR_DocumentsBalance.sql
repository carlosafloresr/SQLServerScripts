USE IMC
GO

DROP TABLE [dbo].[AR_DocumentsBalance]
GO

/****** Object:  Table [dbo].[AR_DocumentsBalance]    Script Date: 3/5/2020 8:40:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AR_DocumentsBalance](
	[AR_DocumentsBalanceId] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerId] [varchar](15) NOT NULL,
	[DocumentNum] [varchar](30) NOT NULL,
	[DocPstgDate] [date] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Balance] [numeric](12, 2) NOT NULL,
	[DocType] Smallint,
	[Void] [bit] NOT NULL
 CONSTRAINT [PK_AR_DocumentsBalance_Main] PRIMARY KEY CLUSTERED 
(
	[AR_DocumentsBalanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE INDEX AR_DocumentsBalance_CustomerId ON AR_DocumentsBalance (CustomerId)
GO

CREATE INDEX AR_DocumentsBalance_DocumentNum ON AR_DocumentsBalance (DocumentNum)
GO

CREATE INDEX AR_DocumentsBalance_PostDate ON AR_DocumentsBalance (DocPstgDate)
GO

CREATE INDEX AR_DocumentsBalance_ActivityDate ON AR_DocumentsBalance (ActivityDate)
GO

CREATE INDEX AR_DocumentsBalance_Balance ON AR_DocumentsBalance (Balance)
GO

CREATE INDEX AR_DocumentsBalance_DocType ON AR_DocumentsBalance (DocType)
GO

ALTER PROCEDURE USP_AR_DocumentsBalance
		@Customer		Varchar(15),
		@Document		Varchar(30),
		@DocPstgDate	Date,
		@ActivDate		Date,
		@Amount			Numeric(12,2),
		@DocType		Smallint,
		@Void			Bit
AS
SET NOCOUNT ON

DECLARE @RecordId	Bigint

SET @RecordId = (SELECT AR_DocumentsBalanceId FROM AR_DocumentsBalance WHERE CustomerId = @Customer AND DocumentNum = @Document)

IF @RecordId IS Null
	INSERT INTO AR_DocumentsBalance
			([CustomerId],
			[DocumentNum],
			[DocPstgDate],
			[ActivityDate],
			[Balance],
			[DocType],
			[Void])
	VALUES	
			(@Customer,
			@Document,
			@DocPstgDate,
			@ActivDate,
			@Amount,
			@DocType,
			@Void)
ELSE
	UPDATE	AR_DocumentsBalance
	SET		[ActivityDate]	= DATA.ActivityDate,
			[Balance]		= DATA.Balance,
			[Void]			= @Void
	FROM	(
			SELECT	CustomerId,
					DocumentNum,
					DocAmount - SUM(Balance) AS Balance,
					ISNULL(MAX(AppPstgDate), DocPstgDate) AS ActivityDate,
					Void
			FROM	(
					SELECT	DAT.CUSTNMBR AS CustomerId,
							DAT.DOCNUMBR AS DocumentNum,
							DAT.GLPOSTDT AS DocPstgDate,
							DAT.ORTRXAMT AS DocAmount,
							DAT.VOIDSTTS AS Void,
							APP.APPTOAMT AS Balance,
							APP.GLPOSTDT AS AppPstgDate
					FROM	IMC.dbo.RM30101 DAT WITH(NOLOCK)
							LEFT JOIN dbo.RM30201 APP WITH(NOLOCK) ON DAT.CUSTNMBR = APP.CUSTNMBR AND DAT.DOCNUMBR = IIF(DAT.RMDTYPAL > 6, APP.APFRDCNM, APP.APTODCNM) AND DAT.RMDTYPAL = IIF(DAT.RMDTYPAL > 6, APP.APFRDCTY, APP.APTODCTY)
					WHERE	DAT.VOIDSTTS = 0
							AND DAT.CUSTNMBR = @Customer
							AND DAT.DOCNUMBR = @Document
					) DATA
			GROUP BY
					CustomerId,
					DocumentNum,
					DocPstgDate,
					DocAmount,
					Void
			) DATA
	WHERE	AR_DocumentsBalanceId = @RecordId

GO

ALTER TRIGGER [dbo].[TRG_RM30101_DocumentBalances] ON [dbo].[RM30101]
AFTER INSERT, UPDATE
AS  
DECLARE	@Customer		Varchar(15),
		@Document		Varchar(30),
		@DocPstgDate	Date,
		@ActivDate		Date,
		@Amount			Numeric(12,2),
		@DocType		Smallint,
		@Void			Bit		
		
SELECT	@Customer		= CUSTNMBR,
		@Document		= DOCNUMBR,
		@DocPstgDate	= GLPOSTDT,
		@ActivDate		= IIF(GLPOSTDT < '01/01/1980', DOCDATE, GLPOSTDT),
		@Amount			= ORTRXAMT,
		@DocType		= RMDTYPAL,
		@Void			= VOIDSTTS
FROM	Inserted

BEGIN TRY
  EXECUTE dbo.USP_AR_DocumentsBalance @Customer, @Document, @DocPstgDate, @ActivDate, @Amount, @DocType, @Void
END TRY
BEGIN CATCH
	PRINT ''
END CATCH