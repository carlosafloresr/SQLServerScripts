USE [Integrations]
GO 

SET NOCOUNT ON

DECLARE	@BatchId		Varchar(22) = '9FSI20230126_1006',
		@Company		Varchar(15),
		@Integration	Varchar(10) = 'FSIG', --FSI,FSIG,FSIP,TIP
		@Script			Char(1) = 'U',
		@TIP_AR			Bit = 1,
		@TIP_AP			Bit = 1,
		@Reversal		Bit = 0,
		@Validated		Bit = 0,
		@Reprocess		Bit = 0,
		@Status			Smallint = 0,
		@GPServer		Varchar(15) = 'PRISQL01P',
		@Demurrage		Varchar(10)

SET @Company		= (SELECT Company FROM FSI_ReceivedHeader WITH (NOLOCK) WHERE BatchId = @BatchId)
SET @Integration	= UPPER(@Integration)
SET @Demurrage		= (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WITH (NOLOCK) WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')

PRINT 'Company: ' + ISNULL(@Company, 'Not Found')

IF @Script = 'U' AND @Company IS NOT Null
BEGIN
	DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
	--DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))

	INSERT INTO @tblVendors
	SELECT	Company, 
			VendorId,
			'PP'
	FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster  WITH (NOLOCK)
	WHERE	Company = @Company 

	SET NOCOUNT OFF

	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WITH (NOLOCK) WHERE Integration = @Integration AND BatchId = @BatchId) -- IN ('FSI','FSIG','FSIP','TIP')
		UPDATE	ReceivedIntegrations 
		SET		Status = @Status, GPServer = @GPServer, ReverseBatch = @Reversal, Integration = UPPER(Integration), Validated = @Validated, Reprocess = @Reprocess
		WHERE	Integration IN (@Integration)
				AND BatchId = @BatchId
	ELSE
		INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer, Status, ReverseBatch, Validated, Reprocess) VALUES (@Integration, @Company, @BatchId, @GPServer, @Status, @Reversal, @Validated, @Reprocess)

	IF @Integration IN ('FSIG','FSIP','TIP')
	BEGIN
		IF @Integration = 'TIP' AND @TIP_AR = 1
		BEGIN
			PRINT 'TIP SALES'

			UPDATE	FSI_ReceivedDetails 
			SET		Processed = 0 
			WHERE	BatchId  = @BatchId
					AND (Intercompany = 1 OR ICB = 1)
					--AND FSI_ReceivedDetailId IN (8871579)
		END

		IF @Integration IN ('FSIG','FSIP') OR (@Integration = 'TIP' AND @TIP_AP = 1)
		BEGIN
			IF @Integration = 'FSIP'
			BEGIN
				UPDATE	FSI_ReceivedSubDetails 
				SET		Processed = @Status, 
						Verification = Null 
				WHERE	FSI_ReceivedSubDetailId IN (SELECT FSI_ReceivedSubDetailId FROM View_Integration_FSI_Vendors WHERE BatchId = @BatchId)
						--AND FSI_ReceivedSubDetailId IN (43022180)
			END

			IF @Integration = 'FSIG'
			BEGIN
				UPDATE	FSI_ReceivedSubDetails 
				SET		Processed = @Status, 
						Verification = Null
				WHERE	BatchId = @BatchId 
						AND ((((PrePay = 1 AND ISNULL(PrePayType, '') IN ('','P')) 
						OR PrePayType = 'A' 
						OR PerDiemType = 1 
						OR AccCode = @Demurrage -- AND DetailId IN (SELECT DetailId FROM FSI_ReceivedDetails WHERE CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)))
						OR RecordCode IN (SELECT VendorCode FROM @tblVendors))))
						AND VndIntercompany = 0
						--AND FSI_ReceivedSubDetailId IN (45787130)
			END

			IF @Integration = 'TIP' AND @TIP_AP = 1
			BEGIN
				UPDATE	FSI_ReceivedSubDetails 
				SET		Processed = @Status, 
						Verification = Null
				WHERE	BatchId = @BatchId 
						AND RecordType = 'VND'
						AND (VndIntercompany = 1 OR ICB = 1)
						--AND FSI_ReceivedSubDetailId IN (38440915)
			END

			DELETE	FSI_PayablesRecords 
			WHERE	RecordId IN (SELECT FSI_ReceivedSubDetailId FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND')
		END
	END
	ELSE
	BEGIN
		PRINT 'FSI INTEGRATION'

		UPDATE	FSI_ReceivedHeader 
		SET		Status = @Status
		WHERE	BatchId = @BatchId

		UPDATE	FSI_ReceivedDetails 
		SET		Processed = @Status
		WHERE	BatchId  = @BatchId 
				--AND InvoiceNumber IN ('50-121473')
	END
END

IF @Script = 'D'
BEGIN
	SET NOCOUNT OFF

	DELETE ReceivedIntegrations WHERE BatchId = @BatchId
	DELETE FSI_ReceivedHeader WHERE BatchId = @BatchId
	DELETE FSI_ReceivedDetails WHERE BatchId = @BatchId --AND FSI_ReceivedDetailId >= 1486992
	DELETE FSI_ReceivedSubDetails WHERE BatchId = @BatchId --AND FSI_ReceivedSubDetailId >= 6629283
END

IF @Script = 'S'
BEGIN
	SELECT * FROM ReceivedIntegrations WHERE BATCHID = @BatchId
	SELECT * FROM FSI_ReceivedHeader WHERE BATCHID = @BatchId --ORDER BY InvoiceNumber --AND VoucherNumber = '12-13629'
	SELECT * FROM FSI_ReceivedDetails WHERE BATCHID = @BatchId --AND CustomerNumber = 'SHIIRV' --AND Processed = 0 
	----AND InvoiceNumber IN ('44-100002','44-100008','44-100009','44-100011','44-100012','44-100015','44-100016','44-100017','44-100025','44-100030','44-100035')
	ORDER BY DetailId --AND LEN(VoucherNumber) > 17
	
	SELECT * FROM FSI_ReceivedSubDetails WHERE BATCHID = @BatchId ORDER BY DetailId--AND RecordType = 'VND' ORDER BY DetailId, FSI_ReceivedSubDetailId
END
/*
DELETE	Integrations.dbo.FSI_ReceivedSubDetails 
WHERE	BatchId  = '1FSI20170627_1818'
		AND RecordCode = '398'

-- DETAIL
UPDATE	Integrations.dbo.FSI_ReceivedDetails 
SET		CustomerNumber = '23764'
		--VoucherNumber = 'RDBULAIR102817',
		--InvoiceNumber = 'RDBULAIR102817',
		--ApplyTo = 'RDBULAIR102817'
WHERE	BatchId  = '4FSI20180614_1632'
		AND CustomerNumber = 'MR1510'
		--AND FSI_ReceivedDetailId = 4532548

-- SUBDETAIL
UPDATE	Integrations.dbo.FSI_ReceivedSubDetails 
SET		RecordCode = '50061O'
WHERE	BatchId = '5FSI20221229_1631'
		AND RecordCode = '500610'
		--AND VendorDocument IN ('C0002833955','C0002835087','C0002827100')

SendXML Error: Sql procedure error codes returned:
Error Number = 190  Stored Procedure taRMTransaction  Error Description = Document number (DOCNUMBR) already exists in either RM00401, RM10301, RM20101 or RM30101
Node Identifier Parameters: taRMTransaction                                    
RMDTYPAL = 1
DOCNUMBR = 15_09_D9-106078-AB
DOCDATE = 1/15/2011
BACHNUMB = '1FSI20141125_1746'
CUSTNMBR = 8926
*/

--SELECT * FROM FSI_ReceivedSubDetails WHERE RecordType = 'VND'
--SELECT * FROM FSI_ReceivedDetails WHERE InvoiceNumber = '16-126018'
--SELECT * FROM View_Integration_FSI WHERE BatchId = '2FSI110308_1747' AND InvoiceTotal <> 0 AND Processed = 0 ORDER BY FSI_ReceivedDetailId

--IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = 'FSIP' AND BatchId = @BatchId)
--	UPDATE ReceivedIntegrations SET Status = 0, GPServer = 'SECSQL01T' WHERE Integration = 'FSIP' AND BatchId = @BatchId
--ELSE
--	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('FSIP', @Company, @BatchId, 'SECSQL01T')

/*

SELECT	*
FROM	FSI_ReceivedHeader
WHERE	BatchId LIKE '9FSI20230116_12%'

SELECT	* 
FROM	GLSO.dbo.GL20000 
WHERE	REFRENCE = 'PN:95-138645/CNT:ECMU445720' 
		AND (CRDTAMNT + DEBITAMT) = 1121.58 
		AND TRXDATE = '10/19/2019'

SELECT	* 
FROM	GLSO.dbo.GL20000 
WHERE	REFRENCE = 'PN:95-138889/CNT:TTNU117532' 
		AND (CRDTAMNT + DEBITAMT) = 974.68
		AND TRXDATE = '10/19/2019'
*/