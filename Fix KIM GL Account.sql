SELECT * FROM KarmakIntegration WHERE KIMBatchId = 'KM1102141823' AND CustomerNumber NOT IN ('RCMR','AIS','GIS') AND Approved = 1 AND Account1 = '1-23-6315'

-- UPDATE KarmakIntegration set Account1 = '1-09-6315' WHERE KIMBatchId = 'KM1102141823' AND CustomerNumber NOT IN ('RCMR','AIS','GIS') AND Approved = 1 and Account1 = '1-23-6315'