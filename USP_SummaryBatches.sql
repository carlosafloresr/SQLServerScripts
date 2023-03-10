USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_SummaryBatches]    Script Date: 08/25/2009 11:43:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_SummaryBatches]		
		@Company		Varchar(5),
		@Inv_No			Varchar(10),
		@Inv_Date		Datetime,
		@Acct_No		Varchar(10),
		@Inv_Total		Decimal(11,2),
		@Inv_Mech		Varchar(10),
		@Container		Varchar(15),
		@Chassis		Varchar(15),
		@Inv_Batch		Varchar(20),
		@Processed		Int = 0
AS
IF EXISTS(SELECT RecId FROM SummaryBatches WHERE Company = @Company AND Inv_No = @Inv_No)
BEGIN
	UPDATE	SummaryBatches
	SET		Inv_Mech	= @Inv_Mech,
			Container	= @Container,
			Chassis		= @Chassis,
			Inv_Batch	= @Inv_Batch,
			ProcessDate	= GETDATE()
	WHERE	Company = @Company 
			AND Inv_No = @Inv_No
END
ELSE
BEGIN
	INSERT INTO SummaryBatches
			(Company
			,Inv_No
			,Inv_Date
			,Acct_No
			,Inv_Total
			,Inv_Mech
			,Container
			,Chassis
			,Inv_Batch)
	VALUES (@Company
			,@Inv_No
			,@Inv_Date
			,@Acct_No
			,@Inv_Total
			,@Inv_Mech
			,@Container
			,@Chassis
			,@Inv_Batch)
END

--DELETE SummaryBatches WHERE Company = 'FI' AND Inv_No = '345802'
select * from SummaryBatches where inv_no = '345802'