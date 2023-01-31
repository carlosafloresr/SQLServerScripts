CREATE PROCEDURE USP_SafetyBonus
DECLARE	@Company		char(6)
		,@VendorId		varchar(10)
		,@OldDriverId	varchar(10)
		,@VendorName	varchar(50)
		,@HireDate	datetime
		,@Period, char(6)
		,@PayDate, smalldatetime
		,@BonusPayDate, datetime
		,@Miles, int
		,@ToPay, numeric(38,2)
		,@PreviousMiles	int
		,@PreviousToPay	numeric(38,2)
		,@SortColumn	int
		,@WeeksCounter	int
		,@Paid			bit
AS
INSERT INTO GPCustom.dbo.SafetyBonus
           (Company
           ,VendorId
           ,OldDriverId
           ,VendorName
           ,HireDate
           ,Period
           ,PayDate
           ,BonusPayDate
           ,Miles
           ,ToPay
           ,PreviousMiles
           ,PreviousToPay
           ,SortColumn
           ,WeeksCounter
           ,Paid)
     VALUES
           (@Company, char(6)
           ,@VendorId, varchar(10)
           ,@OldDriverId, varchar(10)
           ,@VendorName, varchar(50)
           ,@HireDate, datetime
           ,@Period, char(6)
           ,@PayDate, smalldatetime
           ,@BonusPayDate, datetime
           ,@Miles, int
           ,@ToPay, numeric(38,2)
           ,@PreviousMiles, int
           ,@PreviousToPay, numeric(38,2)
           ,@SortColumn, int
           ,@WeeksCounter, int
           ,@Paid, bit)
GO


