USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_EBE_ShortPay_DocumentInfo]    Script Date: 2/3/2016 9:20:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_EBE_ShortPay_DocumentInfo 'GIS', '7000S-1406'
EXECUTE USP_EBE_ShortPay_DocumentInfo 'AIS', '27-114053-A'
EXECUTE USP_EBE_ShortPay_DocumentInfo 'AIS', 'DM-A2856A'
*/
ALTER PROCEDURE [dbo].[USP_EBE_ShortPay_DocumentInfo]
		@CompanyId	Varchar(5),
		@InvoiceNum	Varchar(30)
AS
DECLARE	@Query		Varchar(MAX),
		@CompanyNum	Int,
		@Customer	Varchar(30)

DECLARE	@tblDocument Table
	(
		Company_Number		Int,
		GP_InvoiceNumber	Varchar(30),
		GP_CusomerId		Varchar(15),
		GP_CustomerName		Varchar(80),
		GP_OriginalAmount	Numeric(10,2),
		GP_CurrenatBalance	Numeric(10,2),
		GP_AmountPaid		Numeric(10,2),
		GP_InvoiceNotation	Varchar(MAX),
		GP_CheckNumber		Varchar(30),
		GP_DatePaid			Date,
		ShipperName			Varchar(80) Null,
		ShipperCityState	Varchar(80) Null,
		Consignee			Varchar(80) Null,
		BaseFreight			Numeric(10,2) Null,
		RatingTable			Varchar(10) Null,
		FSC					Numeric(10,2) Null,
		Acc_Sequence		Int Null,
		Acc_Code			Varchar(10) Null,
		Acc_RatingTable		Varchar(10) Null,
		Acc_Description		Varchar(80) Null,
		Acc_Amount			Numeric(10,2) Null,
		Division			Varchar(3),
		CustomerDocuments	Varchar(100) Null
	)

DECLARE	@tblGP Table
	(
		GP_InvoiceNumber	Varchar(30),
		GP_CusomerId		Varchar(15),
		GP_CustomerName		Varchar(80),
		GP_OriginalAmount	Numeric(10,2),
		GP_CurrenatBalance	Numeric(10,2),
		GP_AmountPaid		Numeric(10,2),
		GP_InvoiceNotation	Varchar(MAX),
		GP_CheckNumber		Varchar(30),
		GP_DatePaid			Date
	)

SET @CompanyNum = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @CompanyId)
SET @Query = N'SELECT INV.ShName,
        INV.ShCitySt,
        INV.CnName,
        (SELECT SUM(Total) FROM TRK.InvChrg ICH WHERE ICH.Cmpy_No = INV.Cmpy_No AND ICH.Inv_Code = INV.Code AND ICH.T300_Code = ''FRT'') AS BaseFreight,
        ORD.RateTbl AS Order_RateTbl,
        (SELECT SUM(Total) FROM TRK.InvChrg ICH WHERE ICH.Cmpy_No = INV.Cmpy_No AND ICH.Inv_Code = INV.Code AND ICH.T300_Code = ''FSC'') AS FuelService,
        ACC.Seq,
        ACC.T300_Code,
        ACC.RateTbl AS Acc_RateTbl,
        ACC.Description,
        ACC.Total AS Acc_Amount,
		INV.Div_Code AS Division
FROM    TRK.Invoice INV
        LEFT JOIN TRK.Order ORD ON INV.Or_No = ORD.No
        LEFT JOIN TRK.InvChrg ACC ON INV.Cmpy_No = ACC.Cmpy_No AND INV.Code = ACC.Inv_Code AND ACC.T300_Code NOT IN (''FRT'',''FSC'') AND ACC.Total <> 0
WHERE	INV.Cmpy_No = ' + CAST(@CompanyNum AS Varchar) + '
		AND INV.Code = ''' + @InvoiceNum + ''''

INSERT INTO @tblDocument
		(ShipperName,
		ShipperCityState,
		Consignee,
		BaseFreight,
		RatingTable,
		FSC,
		Acc_Sequence,
		Acc_Code,
		Acc_RatingTable,
		Acc_Description,
		Acc_Amount,
		Division)
EXECUTE USP_QuerySWS @Query

SET @Query = N'SELECT DOC.DocNumbr,
		DOC.CUSTNMBR,
		CUS.CUSTNAME,
		DOC.ORTRXAMT,
		DOC.CURTRXAM,
		DOC.ORTRXAMT - DOC.CURTRXAM AS GP_AmountPaid,
		' + RTRIM(@CompanyId) + '.dbo.GPNotesByInvoice(DOC.CUSTNMBR, DOC.DOCNUMBR) AS Collection_Notes,
		GP_CheckNumber = (SELECT TOP 1 * FROM (SELECT APFRDCNM FROM ' + RTRIM(@CompanyId) + '..RM20201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR UNION SELECT APFRDCNM FROM ' + RTRIM(@CompanyId) + '..RM30201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR) DAT1),
		GP_CheckDate = (SELECT TOP 1 * FROM (SELECT CAST(APFRDCDT AS Date) AS APFRDCDT FROM ' + RTRIM(@CompanyId) + '..RM20201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR UNION SELECT CAST(APFRDCDT AS Date) FROM ' + RTRIM(@CompanyId) + '..RM30201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR) DAT2)
FROM    ' + RTRIM(@CompanyId) + '..RM30101 DOC
        INNER JOIN ' + RTRIM(@CompanyId) + '..RM00101 CUS ON DOC.CUSTNMBR = CUS.CUSTNMBR
WHERE   DOC.RMDTYPAL = 1
        AND DOC.DOCNUMBR = ''' + @InvoiceNum + '''
UNION
SELECT DOC.DocNumbr,
		DOC.CUSTNMBR,
		CUS.CUSTNAME,
		DOC.ORTRXAMT,
		DOC.CURTRXAM,
		DOC.ORTRXAMT - DOC.CURTRXAM AS GP_AmountPaid,
		' + RTRIM(@CompanyId) + '.dbo.GPNotesByInvoice(DOC.CUSTNMBR, DOC.DOCNUMBR) AS Collection_Notes,
		GP_CheckNumber = (SELECT TOP 1 * FROM (SELECT APFRDCNM FROM ' + RTRIM(@CompanyId) + '..RM20201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR UNION SELECT APFRDCNM FROM ' + RTRIM(@CompanyId) + '..RM30201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR) DAT1),
		GP_CheckDate = (SELECT TOP 1 * FROM (SELECT CAST(APFRDCDT AS Date) AS APFRDCDT FROM ' + RTRIM(@CompanyId) + '..RM20201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR UNION SELECT CAST(APFRDCDT AS Date) FROM ' + RTRIM(@CompanyId) + '..RM30201 APP WHERE APP.CUSTNMBR = DOC.CUSTNMBR AND APP.APTODCNM = DOC.DOCNUMBR) DAT2)
FROM    ' + RTRIM(@CompanyId) + '..RM20101 DOC
        INNER JOIN ' + RTRIM(@CompanyId) + '..RM00101 CUS ON DOC.CUSTNMBR = CUS.CUSTNMBR
WHERE   DOC.RMDTYPAL = 1
        AND DOC.DOCNUMBR = ''' + @InvoiceNum + ''''
PRINT @Query
INSERT INTO @tblGP
EXECUTE(@Query)

SET @Customer = (SELECT RTRIM(GP_CusomerId) FROM @tblGP)

IF (SELECT COUNT(*) FROM @tblDocument) = 0
BEGIN
	INSERT INTO @tblDocument
		(Company_Number,
		GP_InvoiceNumber,
		GP_CusomerId,
		GP_CustomerName,
		GP_OriginalAmount,
		GP_CurrenatBalance,
		GP_AmountPaid,
		GP_InvoiceNotation,
		GP_CheckNumber,
		GP_DatePaid)
	SELECT	@CompanyNum, *
	FROM	@tblGP
			
END
ELSE
BEGIN
	UPDATE	@tblDocument
	SET		Company_Number		= @CompanyNum,
			GP_InvoiceNumber	= DATA.GP_InvoiceNumber,
			GP_CusomerId		= DATA.GP_CusomerId,
			GP_CustomerName		= DATA.GP_CustomerName,
			GP_OriginalAmount	= DATA.GP_OriginalAmount,
			GP_CurrenatBalance	= DATA.GP_CurrenatBalance,
			GP_AmountPaid		= DATA.GP_AmountPaid,
			GP_InvoiceNotation	= DATA.GP_InvoiceNotation,
			GP_CheckNumber		= DATA.GP_CheckNumber,
			GP_DatePaid			= DATA.GP_DatePaid
	FROM	(
			SELECT	*
			FROM	@tblGP
			) DATA
END

SET @Query = 'SELECT doccodes, Code FROM com.billto WHERE Code = ''' + @Customer + ''' AND cmpy_no = ''' + CAST(@CompanyNum AS Varchar) + ''''
EXECUTE USP_QuerySWS @Query, '##tmpDocs'

UPDATE	@tblDocument
SET		CustomerDocuments = ##tmpDocs.doccodes
FROM	##tmpDocs
WHERE	[@tblDocument].GP_CusomerId = ##tmpDocs.Code

SELECT	Company_Number,
		GP_InvoiceNumber,
		GP_CusomerId,
		GP_CustomerName,
		GP_OriginalAmount,
		GP_CurrenatBalance,
		GP_AmountPaid,
		GP_InvoiceNotation,
		GP_CheckNumber,
		GP_DatePaid,
		ShipperName,
		ShipperCityState,
		Consignee,
		ISNULL(BaseFreight,0) AS BaseFreight,
		RatingTable,
		ISNULL(FSC,0) AS FSC,
		Acc_Sequence,
		Acc_Code,
		Acc_RatingTable,
		Acc_Description,
		ISNULL(Acc_Amount,0) AS Acc_Amount,
		Division,
		CustomerDocuments
FROM	@tblDocument
--WHERE	ISNUMERIC(Acc_Code) = 1

DROP TABLE ##tmpDocs