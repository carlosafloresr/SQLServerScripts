USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_VendorInvoiceStatus_Details]    Script Date: 9/23/2021 10:30:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_VendorInvoiceStatus_Details 'GSA~184~COSU6160823250'
EXECUTE USP_VendorInvoiceStatus_Details 'GLSO~136~43585W-A'
EXECUTE USP_VendorInvoiceStatus_Details 'GLSO~706~AEQD1712A003A01'
*/
ALTER PROCEDURE [dbo].[USP_VendorInvoiceStatus_Details]
		@KeyField	Varchar(75) = Null
AS
DECLARE	@tblDetails Table
		(DocType	Varchar(15) Null,
		Document	Varchar(30) Null,
		Applied		Numeric(10,2) Null,
		DatePosted	Date Null)

IF @KeyField IS NOT Null
BEGIN
	IF RIGHT(@KeyField, 1) <> '~'
		SET @KeyField = @KeyField + '~'

	DECLARE	@Company	Varchar(5) = LEFT(@KeyField, dbo.AT('~', @KeyField, 1) - 1),
			@VendorId	Varchar(15) = SUBSTRING(@KeyField, dbo.AT('~', @KeyField, 1) + 1, dbo.AT('~', @KeyField, 2) - dbo.AT('~', @KeyField, 1) - 1),
			@Invoice	Varchar(25) = SUBSTRING(@KeyField, dbo.AT('~', @KeyField, 2) + 1, dbo.AT('~', @KeyField, 3) - dbo.AT('~', @KeyField, 2) - 1),
			@Query		Varchar(MAX)

	SET @Query = N'SELECT CASE (CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCTY ELSE APP.DocType END)WHEN 1 THEN ''Invoice'' WHEN 6 THEN ''Check'' WHEN 5 THEN ''Credit Memo'' END AS DocType,
			CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCNM ELSE APP.ApFrDcNm END AS Document,
			CAST(APP.ApFrmAplyAmt AS Numeric(10,2)) AS Applied,
			APP.DocDate AS DatePosted
	FROM	' + @Company + '.dbo.PM20000 TRX
			LEFT JOIN ' + @Company + '.dbo.PM20100 APP ON (TRX.DocNumbr = APP.APTODCNM OR TRX.DocNumbr = APP.ApFrDcNm) AND TRX.VENDORID = APP.VENDORID
	WHERE	TRX.VendorId = ''' + @VendorId + ''' 
			AND TRX.DocNumbr = ''' + @Invoice + ''' 
			AND APP.DocType IS NOT Null
	UNION
	SELECT	CASE (CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCTY ELSE APP.DocType END)WHEN 1 THEN ''Invoice'' WHEN 6 THEN ''Check'' WHEN 5 THEN ''Credit Memo'' END AS DocType,
			CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCNM ELSE APP.ApFrDcNm END AS Document,
			CAST(APP.ApFrmAplyAmt AS Numeric(10,2)) AS Applied,
			APP.DocDate AS DatePosted
	FROM	' + @Company + '.dbo.PM30200 TRX
			LEFT JOIN ' + @Company + '.dbo.PM30300 APP ON (TRX.DocNumbr = APP.APTODCNM OR TRX.DocNumbr = APP.ApFrDcNm) AND TRX.VENDORID = APP.VENDORID
	WHERE	TRX.VendorId = ''' + @VendorId + ''' 
			AND TRX.DocNumbr = ''' + @Invoice + ''' 
			AND APP.DocType IS NOT Null'

	IF @KeyField <> ''
	BEGIN
		--PRINT @Query
		EXECUTE(@Query)
	END
END
ELSE
	SELECT	*
	FROM	@tblDetails

/*
	SET @Query = N'SELECT CASE (CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCTY ELSE APP.DocType END)WHEN 1 THEN ''Invoice'' WHEN 6 THEN ''Check'' WHEN 5 THEN ''Credit Memo'' END AS DocType,
			CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCNM ELSE APP.ApFrDcNm END AS Document,
			CAST(APP.ApFrmAplyAmt AS Numeric(10,2)) AS Applied,
			APP.DocDate AS DatePosted
	FROM	' + @Company + '.dbo.PM20000 TRX
			LEFT JOIN ' + @Company + '.dbo.PM20100 APP ON (TRX.DocNumbr = APP.APTODCNM OR TRX.DocNumbr = APP.ApFrDcNm) AND TRX.VENDORID = APP.VENDORID
	WHERE	TRX.VendorId = ''' + @VendorId + ''' 
			AND TRX.DocNumbr LIKE ''%' + @Invoice + '%'' 
			AND APP.DocType IS NOT Null
	UNION
	SELECT	CASE (CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCTY ELSE APP.DocType END)WHEN 1 THEN ''Invoice'' WHEN 6 THEN ''Check'' WHEN 5 THEN ''Credit Memo'' END AS DocType,
			CASE WHEN APP.ApFrDcNm = TRX.DocNumbr THEN APP.APTODCNM ELSE APP.ApFrDcNm END AS Document,
			CAST(APP.ApFrmAplyAmt AS Numeric(10,2)) AS Applied,
			APP.DocDate AS DatePosted
	FROM	' + @Company + '.dbo.PM30200 TRX
			LEFT JOIN ' + @Company + '.dbo.PM30300 APP ON (TRX.DocNumbr = APP.APTODCNM OR TRX.DocNumbr = APP.ApFrDcNm) AND TRX.VENDORID = APP.VENDORID
	WHERE	TRX.VendorId = ''' + @VendorId + ''' 
			AND TRX.DocNumbr LIKE ''%' + @Invoice + '%'' 
			AND APP.DocType IS NOT Null'
*/