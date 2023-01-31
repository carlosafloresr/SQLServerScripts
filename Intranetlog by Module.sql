DECLARE	@Module		Varchar(100) = 'SWS Trucking/DocPower Inquiry'

SELECT	DISTINCT ILO.UserId,
		DUS.Name
FROM	IntranetLog ILO
		LEFT JOIN GPCustom.dbo.DomainUsers DUS ON ILO.UserId = DUS.UserId
WHERE	ILO.Module = @Module
		AND ILO.UserId <> 'CFLORES'