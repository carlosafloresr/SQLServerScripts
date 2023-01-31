USE GPCustom
GO
/*
EXECUTE USP_AP_HistoricalTrialReport 'GLSO', '12/03/2022' 
*/
ALTER PROCEDURE USP_AP_HistoricalTrialReport
		@Company		Varchar(5),
		@AgingDate		Date
AS
/*
============================================================================================================================
VERSION		MODIFIED	USER				MODIFICATION
============================================================================================================================
1.0			11/29/2022	Carlos A. Flores	Pulls the AP historical trial report data and store it for future data inquiry
============================================================================================================================
*/
SET NOCOUNT ON

DECLARE @RC int
DECLARE @I_dAgingDate datetime = @AgingDate
DECLARE @I_cStartVendorID char(15) = ''
DECLARE @I_cEndVendorID char(15) = 'ZZZZZ'
DECLARE @I_cStartVendorName char(65) = ''
DECLARE @I_cEndVendorName char(65) = 'ZZ'
DECLARE @I_cStartClassID char(15) = ''
DECLARE @I_cEndClassID char(15) = 'ZZ'
DECLARE @I_cStartUserDefined char(15)  = ''
DECLARE @I_cEndUserDefined char(15) = 'ZZ'
DECLARE @I_cStartPaymentPriority char(3) = ''
DECLARE @I_cEndPaymentPriority char(3) = 'ZZ'
DECLARE @I_cStartDocumentNumber char(21) = ''
DECLARE @I_cEndDocumentNumber char(21) = 'ZZ'
DECLARE @I_tUsingDocumentDate tinyint = 0
DECLARE @I_dStartDate datetime = '01/01/1900'
DECLARE @I_dEndDate datetime = @AgingDate
DECLARE @I_tExcludeNoActivity tinyint = 1
DECLARE @I_tExcludeMultiCurrency tinyint = 1
DECLARE @I_tExcludeZeroBalanceVendors tinyint = 1
DECLARE @I_tExcludeFullyPaidTrxs tinyint = 1
DECLARE @I_tExcludeCreditBalance tinyint = 0
DECLARE @I_tExcludeUnpostedAppldCrDocs tinyint = 1

DECLARE	@Query varchar(max)

DECLARE @Out Table (
    [VENDORID] [char](15) NOT NULL,
    [VENDNAME] [char](65) NOT NULL,
    [VNDCLSID] [char](11) NOT NULL,
    [USERDEF1] [char](21) NOT NULL,
    [PYMNTPRI] [char](3) NOT NULL,
    [VEN_KEYSOURC] [char](41) NOT NULL,
    [APTVCHNM] [char](21) NOT NULL,
    [APTODCTY] [smallint] NOT NULL,
    [VCHRNMBR] [char](21) NOT NULL,
    [APP_DOCTYPE] [smallint] NOT NULL,
    [APAMAGPR_1] [numeric](19, 5) NOT NULL,
    [APAMAGPR_2] [numeric](19, 5) NOT NULL,
    [APAMAGPR_3] [numeric](19, 5) NOT NULL,
    [APAMAGPR_4] [numeric](19, 5) NOT NULL,
    [APAMAGPR_5] [numeric](19, 5) NOT NULL,
    [APAMAGPR_6] [numeric](19, 5) NOT NULL,
    [APAMAGPR_7] [numeric](19, 5) NOT NULL,
    [APPLDAMT] [numeric](19, 5) NOT NULL,
    [POSTED] [tinyint] NOT NULL,
    [ORAPPAMT] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_1] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_2] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_3] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_4] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_5] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_6] [numeric](19, 5) NOT NULL,
    [APP_OAGPRAMT_7] [numeric](19, 5) NOT NULL,
    [CNTRLNUM] [char](21) NOT NULL,
    [CNTRLTYP] [smallint] NOT NULL,
    [DOCNUMBR] [char](21) NOT NULL,
    [DOC_DOCTYPE] [smallint] NOT NULL,
    [DOCAMNT] [numeric](19, 5) NOT NULL,
    [DISTKNAM] [numeric](19, 5) NOT NULL,
    [DOCDATE] [datetime] NOT NULL,
    [DUEDATE] [datetime] NOT NULL,
    [DISCDATE] [datetime] NOT NULL,
    [TRXSORCE] [char](13) NOT NULL,
    [CURTRXAM] [numeric](19, 5) NOT NULL,
    [EAMAGPER_1] [numeric](19, 5) NOT NULL,
    [EAMAGPER_2] [numeric](19, 5) NOT NULL,
    [EAMAGPER_3] [numeric](19, 5) NOT NULL,
    [EAMAGPER_4] [numeric](19, 5) NOT NULL,
    [EAMAGPER_5] [numeric](19, 5) NOT NULL,
    [EAMAGPER_6] [numeric](19, 5) NOT NULL,
    [EAMAGPER_7] [numeric](19, 5) NOT NULL,
    [DISAMTAV] [numeric](19, 5) NOT NULL,
    [PERIODID] [smallint] NOT NULL,
    [WROFAMNT] [numeric](19, 5) NOT NULL,
    [DOC_KEYSOURC] [char](41) NOT NULL,
    [DINVPDOF] [datetime] NOT NULL,
    [PSTGDATE] [datetime] NOT NULL,
    [ORDOCAMT] [numeric](19, 5) NOT NULL,
    [ORDISTKN] [numeric](19, 5) NOT NULL,
    [ORCTRXAM] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_1] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_2] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_3] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_4] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_5] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_6] [numeric](19, 5) NOT NULL,
    [DOC_OAGPRAMT_7] [numeric](19, 5) NOT NULL,
    [ODISAMTAV] [numeric](19, 5) NOT NULL,
    [ORWROFAM] [numeric](19, 5) NOT NULL,
    [DEX_ROW_ID] [int] NOT NULL
)

SET @Query = N'EXECUTE [' + @Company + '].[dbo].[seepmHATBWrapper] '
SET @Query = @Query + '''' + CAST(@I_dAgingDate AS Varchar) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartVendorID) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndVendorID) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartVendorName) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndVendorName) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartClassID) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndClassID) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartUserDefined) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndUserDefined) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartPaymentPriority) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndPaymentPriority) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cStartDocumentNumber) + ''','
SET @Query = @Query + '''' + RTRIM(@I_cEndDocumentNumber) + ''','
SET @Query = @Query + '''' + CAST(@I_tUsingDocumentDate AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_dStartDate AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_dEndDate AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeNoActivity AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeMultiCurrency AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeZeroBalanceVendors AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeFullyPaidTrxs AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeCreditBalance AS Varchar) + ''','
SET @Query = @Query + '''' + CAST(@I_tExcludeUnpostedAppldCrDocs AS Varchar) + ''''

DELETE	AP_HistoricalTrialData
WHERE	Company = @Company
		AND AgingDate = @AgingDate

INSERT INTO @Out
EXECUTE(@Query)

DECLARE @tblTrialData	Table (
		Company			Varchar(5),
		AgingDate		Date,
		RunDate			Date,
		VENDORID		Varchar(15),
		VENDNAME		Varchar(100),
		VNDCLASS		Varchar(15),
		DOCDATE			Date, 
		POSTDATE		Date,
		DOCTYPE			Varchar(20),
		DOCNUMBR		Varchar(30),
		DOCAMNT			Numeric(12,2),
		CURTRXAM		Numeric(12,2),
		[0_to_30_Days]	Numeric(12,2),
		[31_to_60_Days]	Numeric(12,2),
		[61_to_90_Days]	Numeric(12,2),
		[91_and_Over]	Numeric(12,2))

INSERT INTO @tblTrialData
SELECT	UPPER(@Company) AS Company,
		@AgingDate AS AgingDate,
		GETDATE() AS RunDate,
		VENDORID,
		VENDNAME,
		VNDCLSID,
		DOCDATE,
		PSTGDATE,
		DOC_DOCTYPE AS DOCTYPE,
		DOCNUMBR,
		DOCAMNT,
		CURTRXAM,
		EAMAGPER_1 + APAMAGPR_1 AS [0_to_30_Days],
		EAMAGPER_2 + APAMAGPR_2 AS [31_to_60_Days],
		EAMAGPER_3 + APAMAGPR_3 AS [61_to_90_Days],
		EAMAGPER_4 + APAMAGPR_4 AS [91_and_Over]
FROM	@Out

INSERT INTO AP_HistoricalTrialData
SELECT	Company,
		AgingDate,
		RunDate,
		VENDORID,
		VENDNAME,
		VNDCLASS,
		DOCDATE, 
		POSTDATE,
		DOCTYPE,
		DOCNUMBR,
		DOCAMNT,
		CURTRXAM,
		[0_to_30_Days],
		[31_to_60_Days],
		[61_to_90_Days],
		[91_and_Over]
FROM	@tblTrialData