USE [IMC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRG_RM30101_DocumentBalances] ON [dbo].[RM30101]
AFTER INSERT, UPDATE
AS  
DECLARE	@Customer	Varchar(15),
		@Document	Varchar(30),
		@ActivDate	Date,
		@Amount		Numeric(12,2),
		@Void		Bit		
		
SELECT	@Customer	= CUSTNMBR,
		@Document	= DOCNUMBR,
		@ActivDate	= IIF(GLPOSTDT < '01/01/1980', DOCDATE, GLPOSTDT),
		@Amount		= ORTRXAMT,
		@Void		= VOIDSTTS
FROM	Inserted

BEGIN TRY
  EXECUTE dbo.USP_AR_DocumentsBalance @Customer, @Document, @ActivDate, @Amount, @Void
END TRY
BEGIN CATCH
	PRINT ''
END CATCH