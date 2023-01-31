USE [Integrations]
GO

CREATE PROCEDURE USP_Integrations_Cash
		@Integration	varchar(10),
		@Company		varchar(5),
		@BACHNUMB		varchar(15),
		@CUSTNMBR		varchar(15),
		@DOCNUMBR		varchar(21),
		@DOCDATE		date,
		@ORTRXAMT		numeric(10,2),
		@GLPOSTDT		date,
		@CSHRCTYP		smallint,
		@CHEKBKID		varchar(15),
		@CHEKNMBR		varchar(21),
		@CRCARDID		varchar(15),
		@TRXDSCRN		varchar(31),
		@APTODCNM		varchar(25) = Null,
		@APTODCTY		smallint = Null,
		@APPTOAMT		numeric(10,2) = Null,
		@Comment		varchar(1000) = Null
AS
INSERT INTO [dbo].[Integrations_Cash]
           ([Integration]
           ,[Company]
           ,[BACHNUMB]
           ,[CUSTNMBR]
           ,[DOCNUMBR]
           ,[DOCDATE]
           ,[ORTRXAMT]
           ,[GLPOSTDT]
           ,[CSHRCTYP]
           ,[CHEKBKID]
           ,[CHEKNMBR]
           ,[CRCARDID]
           ,[TRXDSCRN]
           ,[APTODCNM]
           ,[APTODCTY]
           ,[APPTOAMT]
           ,[Comment])
     VALUES
           (@Integration
           ,@Company
           ,@BACHNUMB
           ,@CUSTNMBR
           ,@DOCNUMBR
           ,@DOCDATE
           ,@ORTRXAMT
           ,@GLPOSTDT
           ,@CSHRCTYP
           ,@CHEKBKID
           ,@CHEKNMBR
           ,@CRCARDID
           ,@TRXDSCRN
           ,@APTODCNM
           ,@APTODCTY
           ,@APPTOAMT
           ,@Comment)
GO


