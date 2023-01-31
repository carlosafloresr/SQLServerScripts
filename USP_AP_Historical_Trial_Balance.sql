/*
EXECUTE USP_AP_Historical_Trial_Balance 'AIS', '03/17/2022', '1005'
*/
ALTER PROCEDURE USP_AP_Historical_Trial_Balance
	@Company			Varchar(5),
	@AgingDate			Date,
	@VendorId			Varchar(30) = Null,
	@Summary			Bit = 0
AS
SET NOCOUNT ON

IF @AgingDate IS Null
	SET @AgingDate = GETDATE()
 
DECLARE @tblAPAging		Table (
    [VENDORID]			Char(15) NOT NULL,
    [VENDNAME]			Char(65) NOT NULL,
    [VNDCLSID]			Char(11) NOT NULL,
    [USERDEF1]			Char(21) NOT NULL,
    [PYMNTPRI]			Char(3) NOT NULL,
    [VEN_KEYSOURC]		Char(41) NOT NULL,
    [APTVCHNM]			Char(21) NOT NULL,
    [APTODCTY]			Smallint NOT NULL,
    [VCHRNMBR]			Char(21) NOT NULL,
    [APP_DOCTYPE]		Smallint NOT NULL,
    [APAMAGPR_1]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_2]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_3]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_4]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_5]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_6]		Numeric(12, 2) NOT NULL,
    [APAMAGPR_7]		Numeric(12, 2) NOT NULL,
    [APPLDAMT]			Numeric(12, 2) NOT NULL,
    [POSTED]			Tinyint NOT NULL,
    [ORAPPAMT]			Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_1]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_2]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_3]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_4]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_5]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_6]	Numeric(12, 2) NOT NULL,
    [APP_OAGPRAMT_7]	Numeric(12, 2) NOT NULL,
    [CNTRLNUM]			Char(21) NOT NULL,
    [CNTRLTYP]			Smallint NOT NULL,
    [DOCNUMBR]			Char(21) NOT NULL,
    [DOC_DOCTYPE]		Smallint NOT NULL,
    [DOCAMNT]			Numeric(12, 2) NOT NULL,
    [DISTKNAM]			Numeric(12, 2) NOT NULL,
    [DOCDATE]			Date NOT NULL,
    [DUEDATE]			Date NOT NULL,
    [DISCDATE]			Date NOT NULL,
    [TRXSORCE]			Char(13) NOT NULL,
    [CURTRXAM]			Numeric(12, 2) NOT NULL,
    [EAMAGPER_1]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_2]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_3]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_4]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_5]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_6]		Numeric(12, 2) NOT NULL,
    [EAMAGPER_7]		Numeric(12, 2) NOT NULL,
    [DISAMTAV]			Numeric(12, 2) NOT NULL,
    [PERIODID]			Smallint NOT NULL,
    [WROFAMNT]			Numeric(12, 2) NOT NULL,
    [DOC_KEYSOURC]		Char(41) NOT NULL,
    [DINVPDOF]			Date NOT NULL,
    [PSTGDATE]			Date NOT NULL,
    [ORDOCAMT]			Numeric(12, 2) NOT NULL,
    [ORDISTKN]			Numeric(12, 2) NOT NULL,
    [ORCTRXAM]			Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_1]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_2]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_3]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_4]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_5]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_6]	Numeric(12, 2) NOT NULL,
    [DOC_OAGPRAMT_7]	Numeric(12, 2) NOT NULL,
    [ODISAMTAV]			Numeric(12, 2) NOT NULL,
    [ORWROFAM]			Numeric(12, 2) NOT NULL,
    [DEX_ROW_ID]		Int NOT NULL)
 
INSERT INTO @tblAPAging
EXECUTE seepmHATBWrapper
    @I_dAgingDate = @agingdate,
    @I_cStartVendorID= @VendorId,
    @I_cEndVendorID = @VendorId,
    @I_cStartVendorName = '',
    @I_cEndVendorName = 'þþþþþþþþþþþþþþþ',
    @I_cStartClassID = '',
    @I_cEndClassID = 'þþþþþþþþþþþþþþþ',
    @I_cStartUserDefined = '',
    @I_cEndUserDefined = 'þþþþþþþþþþþþþþþ',
    @I_cStartPaymentPriority = '',
    @I_cEndPaymentPriority = 'þþþþþþþþþþþþþþþ',
    @I_cStartDocumentNumber = '',
    @I_cEndDocumentNumber = 'þþþþþþþþþþþþþþþ',
    @I_tUsingDocumentDate = 0,
    @I_dStartDate = '1/1/1900',
    @I_dEndDate = @agingdate,
    @I_tExcludeNoActivity = '1',
    @I_tExcludeMultiCurrency = '1',
    @I_tExcludeZeroBalanceVendors = '1',
    @I_tExcludeFullyPaidTrxs = '1',
    @I_tExcludeCreditBalance = '0',
    @I_tExcludeUnpostedAppldCrDocs = '1'
 
IF @Summary = 1
BEGIN
	SELECT	RTRIM(VENDORID) AS VendorId,
			RTRIM(VENDNAME) AS VendorName,
			ISNULL(SUM(EAMAGPER_1),0) AS [Current],
			ISNULL(SUM(EAMAGPER_2),0) AS [31-60],
			ISNULL(SUM(EAMAGPER_3),0) AS [61-90],
			ISNULL(SUM(EAMAGPER_4),0) AS [91-180],
			ISNULL(SUM(EAMAGPER_5),0) AS [181-More],
			SUM(EAMAGPER_1 + EAMAGPER_2 + EAMAGPER_3 + EAMAGPER_4 + EAMAGPER_5) AS Balance
	FROM	@tblAPAging
	GROUP BY RTRIM(VENDORID), RTRIM(VENDNAME)
	ORDER BY 1
END
ELSE
BEGIN
	SELECT	RTRIM(VENDORID) AS VendorId,
			RTRIM(VENDNAME) AS VendorName,
			DOCDATE AS TrxDate,
			RTRIM(DOCNUMBR) AS Document,
			DOC_DOCTYPE AS DocType,
			ISNULL(SUM(EAMAGPER_1),0) AS [Current],
			ISNULL(SUM(EAMAGPER_2),0) AS [31-60],
			ISNULL(SUM(EAMAGPER_3),0) AS [61-90],
			ISNULL(SUM(EAMAGPER_4),0) AS [91-180],
			ISNULL(SUM(EAMAGPER_5),0) AS [181-More],
			SUM(EAMAGPER_1 + EAMAGPER_2 + EAMAGPER_3 + EAMAGPER_4 + EAMAGPER_5) AS Balance
	FROM	@tblAPAging
	GROUP BY RTRIM(VENDORID), RTRIM(VENDNAME), DOCDATE, RTRIM(DOCNUMBR), DOC_DOCTYPE
	ORDER BY 1, 3, 4
END