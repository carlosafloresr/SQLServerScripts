DECLARE @KMKInv		Varchar(30),
		@TMTInv		Varchar(30)

DECLARE @tblData	Table (KMK_Inv Varchar(30), TMT_Inv Varchar(30))
DECLARE @tblGLData	Table (KMK_Inv Varchar(30), TMT_Inv Varchar(30), InvType Char(1), GLAcct Varchar(15), Debit Numeric(10,2), Credit Numeric(10,2))

INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49584','51')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49602','65')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49603','66')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49611','67')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49570','154')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49571','167')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49568','168')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49569','169')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49576','170')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49580','171')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49577','172')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49573','173')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49579','174')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49578','175')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49583','176')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49582','177')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49586','178')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49587','179')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49595','181')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49594','182')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49593','185')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49597','186')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49598','187')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49599','188')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49575','189')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49632','190')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49589','191')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49592','192')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49588','193')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49600','194')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49596','195')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49563','197')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49567','198')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49567','198')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49570','199')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49558','200')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49559','204')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49549','206')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49532','207')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49507','208')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49616','209')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49623','210')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49618','211')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49626','211')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49625','212')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49625','212')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49624','213')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49630','214')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49629','215')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49649','217')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49640','218')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49639','219')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49643','220')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49638','221')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49642','222')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49635','223')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49637','224')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49634','225')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49636','226')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49641','227')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49645','228')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49647','229')
INSERT INTO @tblData (KMK_Inv, TMT_Inv) VALUES ('49648','230')

DECLARE curInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	KMK_Inv, 'RO-' + GPCustom.dbo.PADL(TMT_Inv, 9, '0') AS TMT_Inv
FROM	@tblData

OPEN curInvoices 
FETCH FROM curInvoices INTO @KMKInv, @TMTInv

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblGLData
	SELECT	@KMKInv, @TMTInv, 'K', RTRIM(GL05.ACTNUMST) AS ACCOUNT, GL20.DEBITAMT, GL20.CRDTAMNT
	FROM	PRISQL01P.RCCL.dbo.GL20000 GL20
			LEFT JOIN PRISQL01P.RCCL.dbo.GL00105 GL05 ON GL20.ACTINDX = GL05.ACTINDX
	WHERE	GL20.REFRENCE LIKE ('%' + @KMKInv + '%')

	INSERT INTO @tblGLData
	SELECT	@KMKInv, @TMTInv, 'T', RTRIM(GL05.ACTNUMST) AS ACCOUNT, GL20.DEBITAMT, GL20.CRDTAMNT
	FROM	RCCL.dbo.GL20000 GL20
			LEFT JOIN RCCL.dbo.GL00105 GL05 ON GL20.ACTINDX = GL05.ACTINDX
	WHERE	GL20.REFRENCE LIKE ('%' + @TMTInv + '%')

	FETCH FROM curInvoices INTO @KMKInv, @TMTInv
END

CLOSE curInvoices
DEALLOCATE curInvoices

SELECT	*
FROM	@tblGLData
ORDER BY 1, 3, 4