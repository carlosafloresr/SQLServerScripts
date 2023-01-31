/*
EXECUTE USP_LoadRepairsPictures 1260130
EXECUTE USP_LoadRepairsPictures 1245897
*/
ALTER PROCEDURE [dbo].[USP_LoadRepairsPictures] (@InvoiceNo Int)
AS
DECLARE	@ItemCount			Int,
		@PictureCount		Int,
		@PictPerLine		Int,
		@Tablet				Varchar(10),
		@PictureFileName	Varchar(25),
		@ZipFileName		Varchar(25),
		@LineItem			Int,
		@PictureType		Char(1),
		@SavedOn			Datetime,
		@TypeSort			Int,
		@SaveFileName		Varchar(25),
		@Counter1			Int = 1,
		@Counter2			Int = 1,
		@Consecutive		Varchar(30) = 'abcdefghijklmnopqrstuvwxyz',
		@WithLineItem		Int

DECLARE	@Pictures			Table
		(Tablet				Varchar(10),
		PictureFileName		Varchar(25),
		ZipFileName			Varchar(25),
		LineItem			Int,
		PictureType			Char(1),
		SavedOn				Datetime,
		TypeSort			Int,
		SaveFileName		Varchar(25))

SELECT	@ItemCount = COUNT(*)
FROM	RepairsDetails
WHERE	Fk_RepairId IN (SELECT RepairId FROM Repairs WHERE InvoiceNumber = @InvoiceNo)

SELECT	@PictureCount	= COUNT(*),
		@WithLineItem	= SUM(LineItem)
FROM	RepairsPictures
WHERE	Fk_RepairId IN (SELECT RepairId FROM Repairs WHERE InvoiceNumber = @InvoiceNo)
		AND PATINDEX('%SIGN%', PictureFileName) = 0
		
SELECT	@PictPerLine = VarI
FROM	Integrations.dbo.Parameters
WHERE	ParameterCode = 'PICTURESPERLINE'
		AND Company = 'FI'

DECLARE curPictures CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	LEFT(RP.PictureFileName, dbo.AT('_', RP.PictureFileName, 1) - 1) AS Tablet,
		RP.PictureFileName, 
		RTRIM(RH.WorkOrder) + '.zip' AS ZipFileName,
		RP.LineItem,
		RP.PictureType,
		ISNULL(RP.SavedOn, GETDATE()) AS SavedOn,
		TypeSort
FROM	Repairs RH 
		INNER JOIN View_RepairsPictures RP ON RH.RepairId = RP.Fk_RepairId 
WHERE	RH.InvoiceNumber = @InvoiceNo 
		AND PATINDEX('%SIGN%', RP.PictureFileName) = 0
ORDER BY 4, 7, 6

OPEN curPictures 
FETCH FROM curPictures INTO @Tablet, @PictureFileName, @ZipFileName, @LineItem, @PictureType, @SavedOn, @TypeSort

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @WithLineItem > 0
	BEGIN
		SET @Counter1 = @TypeSort
		SET @Counter2 = @LineItem
	END

	SET @SaveFileName = CAST(@InvoiceNo AS Varchar) + '_' + dbo.PADL(@Counter2, 2, '0') + '_' + SUBSTRING(@Consecutive, @Counter1, 1) + '.jpg'
	
	INSERT INTO @Pictures
			(Tablet, PictureFileName, ZipFileName, LineItem, PictureType, SavedOn, TypeSort, SaveFileName)
	VALUES
			(@Tablet, @PictureFileName, @ZipFileName, @LineItem, @PictureType, @SavedOn, @TypeSort, @SaveFileName)

	FETCH FROM curPictures INTO @Tablet, @PictureFileName, @ZipFileName, @LineItem, @PictureType, @SavedOn, @TypeSort

	SET @Counter1 = @Counter1 + 1

	IF @Counter1 > @PictPerLine
	BEGIN
		SET @Counter1 = 1
		SET @Counter2 = @Counter2 + 1
	END
END

CLOSE curPictures
DEALLOCATE curPictures

SELECT	*
FROM	@Pictures