DECLARE	@RecordId		Bigint,
		@Company		Varchar(5),
		@CheckNumber	Varchar(30)

DECLARE curRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CLB.Company,
		CLB.CheckNumber,
		FBN.FileId
FROM	(
		SELECT * FROM GPCustom.dbo.View_CashReceipt WHERE ISNUMERIC(CheckNumber) = 1
		) CLB
		INNER JOIN (
		SELECT * FROM LENSASQL003.FB.dbo.Files WHERE ISNUMERIC(Field5) = 1
		) FBN ON FBN.ProjectId = 161 AND CLB.CheckAccount = Field4 AND LEFT(FBN.Field5, 1) <> '0' AND CAST(CLB.CheckNumber AS Int) = CAST(FBN.Field5 AS Int)
WHERE	CheckNumber <> Field5

OPEN curRecords 
FETCH FROM curRecords INTO @Company, @CheckNumber, @RecordId

WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE	LENSASQL003.FB.dbo.Files
	SET		Field1 = @Company,
			Field5 = @CheckNumber
	WHERE	FileID = @RecordId
							    
	FETCH FROM curRecords INTO @Company, @CheckNumber, @RecordId
END

CLOSE curRecords
DEALLOCATE curRecords
/*
SELECT	DISTINCT CLB.Company,
		CLB.CheckAccount,
		CLB.CheckNumber,
		CLB.CustomerNumber,
		FBN.Field1,
		FBN.Field2,
		FBN.Field3,
		FBN.Field4,
		FBN.Field5,
		FBN.Field6,
		FBN.Field7,
		FBN.Field8,
		FBN.FileId
FROM	(
		SELECT * FROM GPCustom.dbo.View_CashReceipt WHERE ISNUMERIC(CheckNumber) = 1
		) CLB
		INNER JOIN (
		SELECT * FROM LENSASQL003.FB.dbo.Files WHERE ISNUMERIC(Field5) = 1
		) FBN ON FBN.ProjectId = 161 AND CLB.CheckAccount = Field4 AND LEFT(FBN.Field5, 1) <> '0' AND CAST(CLB.CheckNumber AS Int) = CAST(FBN.Field5 AS Int)
WHERE	CLB.BatchId = 'LCKBX092319120000'
		AND CheckNumber <> Field5
ORDER BY CheckAccount, CheckNumber
*/