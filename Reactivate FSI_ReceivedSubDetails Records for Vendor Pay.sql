/*
UPDATE	FSI_ReceivedSubDetails
SET		Processed = 1
WHERE	FSI_ReceivedSubDetailID < 10559999
		AND Processed <> 1

SELECT	DISTINCT InvoiceNumberINTO	#TMPRECORDS
FROM	View_Integration_FSI_Vendors 
WHERE	Company = 'GIS' 
		AND WeekEndDate >= '06/01/2012'

SELECT	*
FROM	FSI_ReceivedSubDetails
WHERE	Batchid = '9FSI20150504_1218'
		AND RecordType = 'VND'
		AND Detailid = 97
		--RecordCode = '16812'
SELECT * FROM View_Integration_FSI_Vendors WHERE RecordType = 'VND' AND Processed = 0 AND VndIntercompany = 0
SELECT * FROM View_Integration_FSI_Full WHERE BatchId = '4FSI20190212_1603' ORDER BY DetailId, RecordType

SELECT	Company, BatchId, InvoiceNumber, CAST(FSI_ReceivedSubDetailId AS Varchar) + ',' AS FSI_ReceivedSubDetailId, DetailId, RecordCode, ChargeAmount1, VendorDocument, Equipment, Division, VndIntercompany, PrePay
FROM	View_Integration_FSI_Full --View_Integration_FSI_Vendors
WHERE	InvoiceNumber IN ('27-163097')
		--Batchid IN ('4FSI20190211_1625')
		--AND RecordType = 'VND'
		--AND PrePay = 0
ORDER BY Batchid, RecordCode, VendorDocument

UPDATE	FSI_ReceivedSubDetails
SET		RecordCode = '771'
WHERE	Batchid IN ('9FSI20180816_1607')
		--AND VendorDocument LIKE 'DEMURRAGE REQUEST%'
		FSI_ReceivedSubDetailId IN (18203971)

*/
SET NOCOUNT OFF

USE [Integrations]
GO

DECLARE	@BatchId	Varchar(25),
		@Company	Varchar(5)

PRINT 'SELECT SUB-DETAIL RECORDS'

SELECT	DISTINCT InvoiceNumber
INTO	#tmpImvoices
FROM	View_Integration_FSI_Vendors
WHERE	VndIntercompany = 0
		AND InvoiceNumber IN ('38-357649',
'38-358011',
'10-138008',
'13-129721',
'13-129773',
'13-129843',
'13-129844',
'13-129845',
'13-130217',
'13-130318',
'22-237268',
'22-237269',
'22-237732',
'22-238348',
'22-238349',
'22-238618',
'22-238619',
'22-238620',
'22-238621',
'22-238622',
'22-238636',
'22-238637',
'22-238672',
'22-238673',
'22-239001',
'22-239202',
'22-239361',
'22-239362',
'22-239363',
'22-239534',
'22-239537',
'22-239538',
'22-239540',
'22-239541',
'22-239667',
'22-239713',
'33-87902',
'7-313206',
'7-313233',
'7-313514',
'7-313607',
'7-313608',
'7-313612',
'7-313616',
'7-313619',
'7-313627',
'7-313630',
'7-313631',
'7-313633',
'7-313635',
'7-313639',
'7-313641',
'7-313745',
'7-313757',
'7-313762',
'7-313765',
'7-313766',
'7-313769',
'7-313770',
'8-621150',
'8-623166',
'8-623169',
'8-623609',
'8-623610',
'8-623611',
'8-623612',
'8-624061',
'8-624348',
'8-624635',
'8-624924',
'8-624929',
'8-625335',
'8-625510',
'8-625511',
'8-625512',
'8-625513',
'8-625514',
'8-625515',
'8-625516',
'8-625517',
'8-625518',
'8-625519',
'8-625823',
'8-625900',
'8-625901',
'8-625993',
'8-626173',
'8-626393',
'8-626882',
'9-352973',
'9-352975',
'9-353113',
'9-353191',
'9-353197',
'9-353198',
'9-353776',
'9-354157',
'9-354158',
'9-354159',
'9-354437',
'9-354438',
'9-354439',
'9-354440',
'9-354441',
'9-354442',
'9-354443',
'9-354444',
'9-354445',
'9-354446',
'9-354521',
'9-354563',
'3-302384',
'3-302386',
'3-302387',
'19-165378',
'19-165379',
'19-165423',
'19-165424',
'19-165466',
'19-165467',
'19-165634',
'19-165635',
'19-165701',
'19-165702',
'19-165738')
		--AND Batchid IN ('4FSI20190211_1625')
		--AND Company = 'NDS'
		--AND FSI_ReceivedSubDetailId IN (18841133,)

SELECT * FROM #tmpImvoices

PRINT 'UPDATING SUB-DETAILS'
UPDATE	FSI_ReceivedSubDetails
SET		Processed = 0
WHERE	RecordType = 'VND'
		--AND RecordCode IN ('771','293','649')
		AND FSI_ReceivedSubDetailId IN (
										SELECT	FSI_ReceivedSubDetailId
										FROM	View_Integration_FSI_Vendors
										WHERE	InvoiceNumber IN (
																	SELECT	InvoiceNumber
																	FROM	#tmpImvoices
																 )
										)

PRINT 'DELETE PAYABLES RECORDS'
DELETE	FSI_PayablesRecords
WHERE	RecordId IN (
					SELECT	FSI_ReceivedSubDetailId
					FROM	View_Integration_FSI_Vendors
					WHERE	InvoiceNumber IN (
												SELECT	InvoiceNumber
												FROM	#tmpImvoices
												) 
					)

DECLARE curFSIBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT Company, BatchId
	FROM	View_Integration_FSI_Vendors
	WHERE	InvoiceNumber IN (
								SELECT	InvoiceNumber
								FROM	#tmpImvoices
							 ) 
OPEN curFSIBatches 
FETCH FROM curFSIBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'RECEIVED INTEGRATIONS'
	IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = 'FSIP' AND BatchId = @BatchId AND Company = @Company)
	BEGIN
		UPDATE	ReceivedIntegrations 
		SET		Status = 0,
				GPServer = 'PRISQL01P'
		WHERE	Integration = 'FSIP' 
				AND BatchId = @BatchId 
				AND Company = @Company
	END
	ELSE
	BEGIN
		INSERT INTO ReceivedIntegrations 
				(Integration, Company, BatchId, GPServer) 
		VALUES 
				('FSIP', @Company, @BatchId, 'ILSGP01')
	END

	PRINT 'Company: ' + @Company + ' / Batch Id: ' + @BatchId

	FETCH FROM curFSIBatches INTO @Company, @BatchId
END

CLOSE curFSIBatches
DEALLOCATE curFSIBatches

DROP TABLE #tmpImvoices