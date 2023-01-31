/*
EXECUTE USP_FSI_IGSFixCodes '9FSI20141229_1320'
*/
ALTER PROCEDURE USP_FSI_IGSFixCodes
	@BatchId	Varchar(25)
AS
--UPDATE	FSI_ReceivedDetails
--SET		CustomerNumber = '11595'
--WHERE	BatchId  = @BatchId
--		AND CustomerNumber = '4770'

UPDATE	FSI_ReceivedDetails
SET		CustomerNumber = '639'
WHERE	BatchId  = @BatchId
		AND CustomerNumber = '639W'

UPDATE	FSI_ReceivedSubDetails
SET		RecordCode = '234'
WHERE	BatchId  = @BatchId
		AND RecordCode = '612'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '249'
WHERE	BatchId  = @BatchId
		AND RecordCode = '10024'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '292'
WHERE	BatchId  = @BatchId
		AND RecordCode IN ('10040','292IGS')

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '278'
WHERE	BatchId  = @BatchId
		AND RecordCode = '2300'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '237'
WHERE	BatchId  = @BatchId
		AND RecordCode IN ('11018','10018')

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '231'
WHERE	BatchId  = @BatchId
		AND RecordCode = '231IGS'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '237'
WHERE	BatchId  = @BatchId
		AND RecordCode = '237IGS'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '238'
WHERE	BatchId  = @BatchId
		AND RecordCode IN ('1491','14910')

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '240'
WHERE	BatchId  = @BatchId
		AND RecordCode = '2269'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '239'
WHERE	BatchId  = @BatchId
		AND RecordCode = '11670'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '102'
WHERE	BatchId  = @BatchId
		AND RecordCode IN ('2487','IMCG')

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '110'
WHERE	BatchId  = @BatchId
		AND RecordCode = 'AIS'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '108'
WHERE	BatchId  = @BatchId
		AND RecordCode = 'GIS'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '293'
WHERE	BatchId  = @BatchId
		AND RecordCode = '1996'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '243'
WHERE	BatchId  = @BatchId
		AND RecordCode = 'BTT'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '109'
WHERE	BatchId  = @BatchId
		AND RecordCode = 'DNJ'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '231IGS'
WHERE	BatchId  = @BatchId
		AND RecordCode = '1910'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '173'
WHERE	BatchId  = @BatchId
		AND RecordCode = '1817'
 
UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '317'
WHERE	BatchId  = @BatchId
		AND RecordCode = '694'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '260'
WHERE	BatchId  = @BatchId
		AND RecordCode = '10017'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '252'
WHERE	BatchId  = @BatchId
		AND RecordCode = '2830'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '231'
WHERE	BatchId  = @BatchId
		AND RecordCode = '231IGS'

UPDATE	FSI_ReceivedSubDetails 
SET		RecordCode = '341'
WHERE	BatchId  = @BatchId
		AND RecordCode = '1354'