/*
EXECUTE USP_ImportFromRoadsideRepairs
*/
ALTER PROCEDURE USP_ImportFromRoadsideRepairs
	@Rundate	Date = Null
AS
SET NOCOUNT ON

IF @Rundate IS Null
	SET @Rundate = GETDATE()

DECLARE	@Company				Varchar(5),
		@CompanyNumber			Int,
		@RepairNumber			Int, 
		@InvoiceDate			Datetime,
		@RepairDate				Datetime,
		@Query					Varchar(1000),
		@AppSource				Varchar(10) = 'RSRA',
		@OTRNumber				Varchar(15),
		@ProNumber				Varchar(12),
		@Chassis				Varchar(15),
		@DriverId				Varchar(15),
		@Division				Varchar(3),
		@Vendor					Varchar(50),
		@Repair					Varchar(15),
		@Failure_Description	Varchar(50),
		@Cost					Numeric(10,2),
		@Repairs				Varchar(15),
		@Details				Varchar(50),
		@ToInsert				Bit,
		@Region					Varchar(3),
		@Principle				Varchar(10),
		@Pool					Varchar(12)

DECLARE	@tblSWSPool TABLE
		(EqOwner				Varchar(10),
		 EqPool					Varchar(12))

DECLARE	@tblSWSOrder TABLE
		(EqRegion				Varchar(3))

DECLARE TableFields CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT Company, RepairNumber, InvoiceDate, Chassis, ProNumber, RepairDate, OTRNumber
FROM	LENSASQL001.GPCustom.dbo.View_RSA_Invoices2
WHERE	Posted = 1
		AND InvoiceDate BETWEEN DATEADD(DD, -5, @Rundate) AND DATEADD(DD, 1, @Rundate)
ORDER BY InvoiceDate

OPEN TableFields
FETCH FROM TableFields INTO @Company, @RepairNumber, @InvoiceDate, @Chassis, @ProNumber, @RepairDate, @OTRNumber

SET @Query	= ''

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE FROM @tblSWSPool
	DELETE FROM @tblSWSOrder

	SET @CompanyNumber = (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
	SET @Query = 'SELECT owner_code, pool FROM COM.Chassis_Pool_Equipment WHERE Code = ''' + RTRIM(@Chassis) + ''''

	INSERT INTO @tblSWSPool
	EXECUTE USP_QUERYSWS @Query

	-- If this is a Chassis Pool equipment and not was previouslly saved we insert the record
	IF @@RowCount > 0 AND NOT EXISTS(SELECT EquipmentCostId FROM EquipmentCost WHERE CompanyId = @Company AND TransactionNumber = @OTRNumber AND AppSource =  @AppSource) AND dbo.AT('-', @ProNumber, 1) > 0
	BEGIN
		PRINT @ProNumber

		SET @Repairs = ''
		SET @Details = ''
		SET @Query = 'SELECT rgn_code FROM TRK.Order WHERE Cmpy_No = ' + CAST(@CompanyNumber AS Varchar) + ' AND Div_Code = ''' + LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1) - 1) + ''' AND Pro = ''' + REPLACE(@ProNumber, LEFT(@ProNumber, dbo.AT('-', @ProNumber, 1)), '') + ''''

		SELECT	@Principle	= EqOwner,
				@Pool		= EqPool
		FROM	@tblSWSPool

		INSERT INTO @tblSWSOrder
		EXECUTE USP_QUERYSWS @Query

		SELECT	@Region		= EqRegion
		FROM	@tblSWSOrder

		IF @Region IS Null OR RTRIM(@Region) = ''
			SET @Region = 'NON'

		DECLARE TableDetails CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	DriverId,
				Division,
				Vendor,
				Repair,
				Failure_Description,
				SUM(Cost) AS Cost
		FROM	(
				SELECT	DriverId,
						Division,
						VendorName AS Vendor,
						CASE WHEN TypeRepair = 1 THEN 'T' + Repair ELSE 'MECH' END AS Repair,
						ISNULL(Failure_Description, Repair) AS Failure_Description,
						LineTotal AS Cost
				FROM	LENSASQL001.GPCustom.dbo.View_RSA_Invoices2
				WHERE	Posted = 1
						AND Company = @Company
						AND RepairNumber = @RepairNumber
				) DATA
		GROUP BY
				DriverId,
				Division,
				Vendor,
				Repair,
				Failure_Description
		ORDER BY Repair, Failure_Description
	
		OPEN TableDetails
		FETCH FROM TableDetails INTO @DriverId, @Division, @Vendor, @Repair, @Failure_Description, @Cost

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Repairs NOT LIKE '%' + RTRIM(@Repair) + '%'
				SET @Repairs = @Repairs + CASE WHEN LEN(@Repairs) = 0 THEN '' ELSE '/' END + RTRIM(@Repair)

			IF @Details NOT LIKE '%' + RTRIM(@Failure_Description) + '%'
				SET @Details = @Details + CASE WHEN LEN(@Details) = 0 THEN '' ELSE '/' END + RTRIM(@Failure_Description)

			FETCH FROM TableDetails INTO @DriverId, @Division, @Vendor, @Repair, @Failure_Description, @Cost
		END

		CLOSE TableDetails
		DEALLOCATE TableDetails

		SET @Pool = ISNULL(@Pool, 'NO POOL')
		SET @RepairDate = ISNULL(@RepairDate, @InvoiceDate)

		EXECUTE USP_EquipmentCost @AppSource, @Company, @Region, @Pool, @Division, @Principle,  @OTRNumber, @Vendor, @DriverId, @RepairDate, @Chassis, 'CH', @Repairs, @Details, @Cost
	END

	FETCH FROM TableFields INTO @Company, @RepairNumber, @InvoiceDate, @Chassis, @ProNumber, @RepairDate, @OTRNumber
END	

CLOSE TableFields
DEALLOCATE TableFields