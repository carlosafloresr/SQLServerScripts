SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Carlos A. Flores>
-- Create date: <12/09/2009 05:25 PM>
-- Description:	<Recover Deleted Records>
-- =============================================
ALTER TRIGGER TRG_EscrowTransactions_OnDelete ON dbo.EscrowTransactions AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO dbo.EscrowTransactions
			([Source]
			,VoucherNumber
			,ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,VendorId
			,DriverId
			,Division
			,Amount
			,ClaimNumber
			,DriverClass
			,AccidentType
			,Status
			,DMSubmitted
			,DeductionPlan
			,Comments
			,ProNumber
			,TransactionDate
			,PostingDate
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,OtherStatus
			,DeletedBy
			,DeletedOn)
	SELECT	[Source]
			,VoucherNumber
			,ItemNumber
			,CompanyId
			,Fk_EscrowModuleId
			,AccountNumber
			,AccountType
			,VendorId
			,DriverId
			,Division
			,Amount
			,ClaimNumber
			,DriverClass
			,AccidentType
			,Status
			,DMSubmitted
			,DeductionPlan
			,Comments
			,ProNumber
			,TransactionDate
			,PostingDate
			,EnteredBy
			,EnteredOn
			,ChangedBy
			,ChangedOn
			,Void
			,InvoiceNumber
			,OtherStatus
			,'TRIGGER'
			,GETDATE()
	FROM	Inserted
END
GO
