USE [IMC]
GO
/****** Object:  Trigger [dbo].[TRG_RM30101_DocumentBalances]    Script Date: 10/27/2020 12:31:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[TRG_RM30101_DocumentBalances] ON [dbo].[RM30101]
AFTER INSERT, UPDATE
AS  
DECLARE     @Customer			Varchar(15),
            @Document			Varchar(30),
            @DocPstgDate		Date,
            @ActivDate			Date,
            @Amount				Numeric(12,2),
            @DocType			Smallint,
            @Void				Bit           
              
SELECT		@Customer			= CUSTNMBR,
            @Document			= DOCNUMBR,
            @DocPstgDate		= GLPOSTDT,
            @ActivDate			= IIF(GLPOSTDT < '01/01/1980', DOCDATE, GLPOSTDT),
            @Amount				= ORTRXAMT,
            @DocType			= RMDTYPAL,
            @Void				= VOIDSTTS
FROM		Inserted

IF (SELECT COUNT(*) FROM Inserted) > 0
BEGIN
	BEGIN TRY
		EXECUTE dbo.USP_AR_DocumentsBalance @Customer, @Document, @DocPstgDate, @ActivDate, @Amount, @DocType, @Void
	END TRY
	BEGIN CATCH
		PRINT ''
	END CATCH
END