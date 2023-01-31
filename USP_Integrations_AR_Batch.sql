/*
EXECUTE USP_Integrations_AR_Batch 'GSAAR', 'GSA', 'IA180822023836'
*/
ALTER PROCEDURE USP_Integrations_AR_Batch
		@Integration	Varchar(6),
		@Company		Varchar(5),
		@BatchId		Varchar(20)
AS
DECLARE	@tblData		Table (
		DOCNUMBR		Varchar(30), 
		CUSTNMBR		Varchar(20), 
		DOCDATE			Date, 
		DOCAMNT			Numeric(10,2), 
		DOCDESCR		Varchar(30), 
		WithApplyTo		Bit, 
		PostingDate		Date,
		ACTNUMST		Varchar(50))

INSERT INTO @tblData
SELECT	DISTINCT DOCNUMBR, CUSTNMBR, DOCDATE, DOCAMNT, DOCDESCR, WithApplyTo, PostingDate, ACTNUMST
FROM	Integrations_AR 
WHERE	Integration = @Integration
		AND BatchId = @BatchID
		AND Company = @Company 
		--AND (Processed = 0 OR (Processed > 0 AND WithApplyTo = 1)) 
		AND CUSTNMBR <> ''

SELECT	DISTINCT DOCNUMBR, CUSTNMBR, DOCDATE, DOCAMNT, DOCDESCR, WithApplyTo, PostingDate
FROM	@tblData