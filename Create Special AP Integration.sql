SET NOCOUNT ON

DECLARE	@Company		Varchar(5) = 'IMC',
		@Integration	Varchar(10) = 'SPCL',
		@BatchId		Varchar(15) = 'SPCLDRIVERBONUS',
		@TrxDate		Date = '03/11/2022',
		@PstDate		Date = '03/11/2022',
		@VCHNUMWK		Varchar(17) = 'SPCLBONUS',
		@TRXDSCRN		Varchar(30) = 'Safety Award Bonus',
		@DOCTYPE		Int = 5,
		@VENDORID		Varchar(15),
		@DOCNUMBR		Varchar(20),
		@DOCAMNT		Numeric(18,2),
		@DOCDATE		Datetime,
		@PSTGDATE		Datetime,
		@CHRGAMNT		Numeric(18,2),
		@TEN99AMNT		Numeric(18,2),
		@PRCHAMNT		Numeric(18,2),
		@CURNCYID		Varchar(15) = 'USD2',
		@RATETPID		Varchar(15) = 'AVERAGE',
		@EXCHDATE		Datetime = '01/01/2007',
		@RATEEXPR		Smallint = 0,
		@CREATEDIST		Smallint = 0,
		@DISTTYPE		Smallint = 6,
		@ACTNUMST		Varchar(75),
		@DEBITAMT		Numeric(18,2),
		@CRDTAMNT		Numeric(18,2),
		@DISTREF		Varchar(30)

DECLARE @tblAPData	Table (VendorId Varchar(15), Amount Numeric(10,2), Account Varchar(15))

-- ="INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('"&B112&"',"&H112&",'"&J112&"')"

INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('75',575,'107-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52117',25,'107-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('9982',300,'107-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('12211E',225,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52411',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50687',100,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50783',175,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51823',75,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50785',175,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52217',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('8863',375,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50483',100,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50689',200,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52333',100,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52167',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51853',100,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('13398',400,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50788',150,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52071',50,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52599',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50794',125,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50795',150,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51942',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52420',0,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52379',25,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50561',100,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52545',225,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52171',225,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52243',0,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50299',225,'108-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52354',25,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52711',25,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51813',50,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50296',325,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('10809',300,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51733',50,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('13225',150,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51996',25,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51737',75,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('8888',350,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51819',50,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('13135',125,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51326',75,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51345',75,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52706',75,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52357',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50020',150,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52515',75,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52287',50,'113-6045') 
--INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50019',325,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('10782',400,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('12196E',225,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50240',125,'113-6045') 
--INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52262',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51999',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51272',100,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51544',150,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52404',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52327',50,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51948',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50171',125,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52375',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52188',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52096',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('12194E',500,'113-6045') 
--INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51618',25,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52132',150,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52552',125,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50600',125,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52687',0,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51985',100,'113-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('12540',225,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('10035',350,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('13467',175,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I50618',175,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I51833',50,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('9989',300,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('8881',375,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('I52279',25,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('9232',350,'109-6045') 
INSERT INTO @tblAPData (VendorId, Amount, Account) VALUES ('12396',225,'109-6045') 

 DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		@VCHNUMWK + '_' + dbo.PADL(RowNumber, 3, '0') AS VCHNUMWK,
		DATA.VendorId,
		'BONUS_' + dbo.PADL(RowNumber, 3, '0') AS DOCNUMBR,
		@DOCTYPE AS DOCTYPE,
		DATA.Amount,
		@TrxDate AS DOCDATE,
		@PstDate AS PSTGDATE,
		DATA.Amount,
		DATA.Amount,
		DATA.Amount,
		@TRXDSCRN AS TRXDSCRN,
		'USD2' AS CURNCYID,
		'AVERAGE' AS RATETPID,
		'01/01/2007'AS EXCHDATE,
		0 AS RATEEXPR,
		0 AS CREATEDIST,
		DATA.DISTTYPE,
		DATA.Account,
		DATA.DEBITAMT,
		DATA.CRDTAMNT,
		@TRXDSCRN AS DISTREF
FROM	(
		SELECT	VendorId,
				Amount,
				6 AS DISTTYPE,
				LEFT(Account, 1) + '-' + SUBSTRING(Account, 2, 10) AS Account,
				0 AS DEBITAMT,
				Amount AS CRDTAMNT,
				ROW_NUMBER() OVER(ORDER BY VendorId) AS RowNumber
		FROM	@tblAPData
		UNION
		SELECT	VendorId,
				Amount,
				2 AS DISTTYPE,
				'0-00-2070' AS Account,
				Amount AS DEBITAMT,
				0 AS CRDTAMNT,
				ROW_NUMBER() OVER(ORDER BY VendorId) AS RowNumber
		FROM	@tblAPData 
		) DATA
ORDER BY VendorId

DELETE Integrations_AP WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId
DELETE ReceivedIntegrations WHERE Integration = @Integration AND Company = @Company AND BatchId = @BatchId

OPEN curData 
FETCH FROM curData INTO @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE, @DOCAMNT, @DOCDATE, @PSTGDATE,
						@CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN, @CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE,
						@ACTNUMST, @DEBITAMT, @CRDTAMNT, @DISTREF

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_Integrations_AP @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE, @DOCAMNT, @DOCDATE, @PSTGDATE,
							@CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN, @CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE,
							@ACTNUMST, @DEBITAMT, @CRDTAMNT, @DISTREF, 0

	FETCH FROM curData INTO @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE, @DOCAMNT, @DOCDATE, @PSTGDATE,
							@CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN, @CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE,
							@ACTNUMST, @DEBITAMT, @CRDTAMNT, @DISTREF
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	EXECUTE USP_ReceivedIntegrations @Integration, @Company, @BatchId, 0

	SELECT	*
	FROM	Integrations_AP 
	WHERE	Integration = @Integration 
			AND Company = @Company 
			AND BatchId = @BatchId
END