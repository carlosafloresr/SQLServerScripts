USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FileBoundFileRequest]    Script Date: 10/14/2020 12:39:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @FileLocation Varchar(300)

--EXECUTE USP_FileBoundFileRequest 63, 2060305, @FileLocation OUT
EXECUTE USP_FileBoundFileRequest 165, 2194864, @FileLocation OUT
PRINT @FileLocation
*/
ALTER PROCEDURE [dbo].[USP_FileBoundFileRequest]
		@ProjectID		Int, 
		@FileId			Int,
		@FileLocation	Varchar(300) OUTPUT,
		@WebLocation	Bit = 0
AS
BEGIN
	DECLARE @xmlOut			varchar(4000),
			@RequestText	varchar(2000)

	SET @RequestText = '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
	  <soap12:Body>
		<GetFile xmlns="http://services.iils.com">
		  <ProjectId>' + CAST(@ProjectID AS Varchar) + '</ProjectId>
		  <FileId>' + CAST(@FileId AS Varchar) + '</FileId>
		</GetFile>
	  </soap12:Body>
	</soap12:Envelope>'

	EXECUTE dbo.spHTTPRequest 'http://services.iils.com/FileBound7FileReader/FileBound7FileReader.asmx', 'POST', @RequestText,  
	'http://services.iils.com/GetFile',
	'', '', @xmlOut OUT

	IF @WebLocation = 1
		SET @xmlOut = REPLACE(@xmlOut, '\\priapint01p\tempfiles\', 'http://PRIAPINT01P/TempFiles/')

	SET @FileLocation = SUBSTRING(@xmlOut, dbo.AT('<GetFileResult>', @xmlOut, 1) + 15, 200)
	SET @FileLocation = SUBSTRING(@FileLocation, 1, dbo.AT('</GetFileResult>', @FileLocation, 1) - 1)
END