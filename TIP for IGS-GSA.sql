/*
EXECUTE USP_TIP_Transactions 'GSA', 'GLSO'
*/
CREATE PROCEDURE USP_TIP_Transactions
		@MainCompany	Varchar(5),
		@SubCompany		Varchar(5)
AS
DECLARE	@Query			Varchar(Max)

DECLARE	@tblData Table (
		AP_VendorId		Varchar(25),
		Ap_Document		Varchar(30),
		Ap_DocDate		Date,
		Ap_DocAmount	Numeric(10,2),
		Ap_BatchNumber	Varchar(30),
		Ap_Description	Varchar(30),
		Ar_CustomerId	Varchar(25) Null,
		Ar_Document		Varchar(30) Null,
		Ar_DocDate		Date Null,
		Ar_BatchNumber	Varchar(30) Null,
		Ar_DocAmount	Numeric(10,2) Null,
		Ar_Description	Varchar(30) Null,
		IsMatch			Char(1) Null,
		Difference		Numeric(10,2) Null)

SET	@Query = N'SELECT	AP.VendorId,
		AP.DOCNUMBR,
		AP.DocDate,
		AP.DocAmnt,
		AP.BachNumb,
		AP.TrxDscrn,
		AR.CustNmbr,
		AR.DOCNUMBR,
		AR.DocDate,
		AR.BachNumb,
		AR.OrTrxAmt,
		AR.TrxDscrn,
		CASE WHEN AP.DocAmnt = AR.OrTrxAmt THEN ''Y'' ELSE ''N'' END AS Match,
		AP.DocAmnt - AR.OrTrxAmt AS Difference
FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000 AP
		INNER JOIN ' + RTRIM(@SubCompany) + '.dbo.RM20101 AR ON AP.DOCNUMBR = AR.DOCNUMBR OR AP.TrxDscrn = AR.TrxDscrn
ORDER BY 6'

INSERT INTO @tblData
EXECUTE(@Query)

--ORDER BY 13 DESC, 6

SELECT	*
FROM	@tblData
ORDER BY 6

--SELECT	*
--FROM	PM20000
--WHERE	TrxDscrn LIKE '%204005554%'

--SELECT	CUSTNMBR,
--		DOCNUMBR,
--		DOCDATE,
--		ORTRXAMT,
--		BACHNUMB,
--		TRXDSCRN,
--		CSPORNBR
--FROM	GLSO.dbo.RM20101 AR
--WHERE	DOCNUMBR IN (SELECT DOCNUMBR FROM PM20000)
