USE [MobileEstimates]
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairsDetails]    Script Date: 06/05/2012 8:20:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_RepairsDetails]
		@Consecutive		int,
		@LineItem			int,
		@PartNumber			varchar(25),
		@PartDescription	varchar(40),
		@LocationCode		varchar(20),
		@DamageCode			varchar(10),
		@RepairCode			varchar(10),
		@DamageWidth		numeric(10,2),
		@DamageLenght		numeric(10,2),
		@EquipmentType		char(1),
		@ResponsibleParty	char(1),
		@Quantity			numeric(10,2),
		@RepairedComponent	varchar(25),
		@DOTIn				varchar(15) = Null,
		@DOTOut				varchar(15) = Null,
		@SubCategory		varchar(30),
		@RecapperOn			Varchar(15) = Null,
		@RecapperOff		Varchar(15) = Null,
		@Position			Varchar(5) = Null
AS
DECLARE	@RepairDetailsId	Int
SET		@RepairDetailsId	= (SELECT RepairDetailsId FROM RepairsDetails WHERE Consecutive = @Consecutive AND LineItem = @LineItem)

BEGIN TRANSACTION

IF @RepairDetailsId IS NULL
BEGIN
	INSERT INTO RepairsDetails
		(Consecutive
		,LineItem
		,PartNumber
		,PartDescription
		,LocationCode
		,DamageCode
		,RepairCode
		,DamageWidth
		,DamageLenght
		,EquipmentType
		,ResponsibleParty
		,Quantity
		,RepairedComponent
		,DOTIn
		,DOTOut
		,SubCategory
		,RecapperOff
		,RecapperOn
		,Position)
     VALUES
		(@Consecutive
		,@LineItem
		,@PartNumber
		,@PartDescription
		,@LocationCode
		,@DamageCode
		,@RepairCode
		,@DamageWidth
		,@DamageLenght
		,@EquipmentType
		,@ResponsibleParty
		,@Quantity
		,@RepairedComponent
		,@DOTIn
		,@DOTOut
		,@SubCategory
		,@RecapperOff
		,@RecapperOn
		,@Position)
END
ELSE
BEGIN
	UPDATE	RepairsDetails
	SET		PartNumber			= @PartNumber,
			PartDescription		= @PartDescription,
			LocationCode		= @LocationCode,
			DamageCode			= @DamageCode,
			RepairCode			= @RepairCode,
			DamageWidth			= @DamageWidth,
			DamageLenght		= @DamageLenght,
			EquipmentType		= @EquipmentType,
			ResponsibleParty	= @ResponsibleParty,
			Quantity			= @Quantity,
			RepairedComponent	= @RepairedComponent,
			DOTIn				= @DOTIn,
			DOTOut				= @DOTOut,
			SubCategory			= @SubCategory,
			RecapperOff			= @RecapperOff,
			RecapperOn			= @RecapperOn,
			Position			= @Position
	WHERE	RepairDetailsId		= @RepairDetailsId
END

IF @@ERROR = 0
BEGIN
	COMMIT TRANSACTION
	RETURN 0
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	RETURN @@ERROR
END