DECLARE	@ReceivedDate	Date = '12/12/2022',
		@BatchDate		Date,
		@BatchId		Varchar(10),
		@Company		Varchar(5)  = 'GLSO'

UPDATE	DMS_ReceivedTransactions
SET		Status = 0
WHERE	CAST(Curr_Date AS Date) = @ReceivedDate

SELECT	@BatchDate	= CAST(DMS.Curr_Date AS Date),
		@BatchId	= DMS.batch_no
FROM	DMS_ReceivedTransactions DMS
		INNER JOIN PRISQL01P.GPCustom.dbo.Companies CPY ON DMS.cmpy_no = CPY.CompanyNumber
WHERE	DMS.Status <> 2
		AND CAST(DMS.Curr_Date AS Date) = @ReceivedDate
		AND CPY.CompanyId = @Company

IF EXISTS(SELECT BatchId FROM ReceivedIntegrations WHERE Integration = 'DMS' AND Company = @Company AND BatchId = @BatchId)
	UPDATE	ReceivedIntegrations 
	SET		Status = 0, 
			GPServer = 'PRISQL01P' 
	WHERE	Integration = 'DMS'
			AND Company = @Company
			AND BatchId = @BatchId
ELSE
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId, GPServer) VALUES ('DMS', @Company, @BatchId, 'PRISQL01P')

SELECT	*
FROM	ReceivedIntegrations
WHERE	Integration = 'DMS'
		AND Company = @Company
		AND BatchId = @BatchId

/*
SELECT	*
FROM	DMS_ReceivedTransactions
WHERE	cmpy_no IN (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = 'GLSO')
		AND CAST(Curr_Date AS Date) = '12/12/2022'

UPDATE	DMS_ReceivedTransactions
SET		GLPRE = '324'
WHERE	cmpy_no IN (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = 'GLSO')
		AND CAST(Curr_Date AS Date) = '12/12/2022'
		AND GLPRE = '003'
*/