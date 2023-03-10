USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_GLIntegration]    Script Date: 7/1/2021 9:32:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_GLIntegration 'GLSO', '9FSI20210629_1318', 'PRISQL01P'
*/
ALTER PROCEDURE [dbo].[USP_FSI_GLIntegration]
		@Company	Varchar(5), 
		@BatchId	Varchar(25),
		@GPServer	Varchar(50) = Null
AS
SET NOCOUNT ON

DECLARE	@WithAR		Bit = 0,
		@WithAP		Bit = 0,
		@WitRows	Bit = 0,
		@Demurrage	Varchar(10) = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')

IF dbo.AT('_SUM', @BatchId, 1) = 0
BEGIN
	DECLARE @tblVendors	Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))

	INSERT INTO @tblVendors
	SELECT	Company,
			VarC,
			'PD'
	FROM	PRISQL01P.GPCustom.dbo.Parameters 
	WHERE	Company = @Company
			AND ParameterCode = 'PRD_VENDORCODE'
	UNION
	SELECT	Company, 
			VendorId,
			'PP'
	FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
	WHERE	Company = @Company 
			AND PierPassType = 1

	SET @WithAP = IIF(EXISTS(SELECT TOP 1 RecordCode FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND'), 1, 0)
	SET @WithAR = IIF(EXISTS(SELECT TOP 1 BatchId FROM FSI_ReceivedDetails WHERE BatchId = @BatchId AND Intercompany = 0 AND (ICB = 1 OR PrePayType IS NOT NULL)), 1, 0)

	PRINT 'With AP: ' + CASE WHEN @WithAP = 1 THEN 'YES' ELSE 'NO' END
	PRINT @Demurrage

	IF @WithAR = 1 OR @WithAP = 1
	BEGIN
		DECLARE	@Param0	Varchar(10) = 'FSIG',
				@Param1	Varchar(5) = @Company,
				@Param2	Varchar(25) = @BatchId,
				@Param3	Varchar(50) = ISNULL(@GPServer, 'PRISQL01P')

		IF @WithAP = 1
		BEGIN
			UPDATE	FSI_ReceivedSubDetails
			SET		FSI_ReceivedSubDetails.Processed = 0
			FROM	(
					SELECT	FSI_ReceivedSubDetailId AS RecordId
					FROM	FSI_ReceivedSubDetails FSI
					WHERE	FSI.BatchId = @BatchId
							AND FSI.RecordType = 'VND'
							AND FSI.VndIntercompany = 0
							AND (((FSI.PrePay = 1 AND ISNULL(FSI.PrePayType, '') IN ('','P')) OR FSI.PrePayType = 'A')
							OR FSI.PerDiemType = 1
							OR FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors)
							OR FSI.AccCode = @Demurrage)
					) DATA
			WHERE	FSI_ReceivedSubDetailId = RecordId

			IF @@ROWCOUNT > 0
				SET @WitRows = 1

			EXECUTE USP_FSI_ReceivedSubDetails_PerDiem @BatchId
		END
		
		IF @WithAR = 1
		BEGIN
			UPDATE	FSI_ReceivedDetails
			SET		Processed = 0
			WHERE	BatchId = @BatchId
					AND Intercompany = 0
					AND (ICB = 1 OR PrePayType IN ('A','P'))

			IF @@ROWCOUNT > 0 AND @WitRows = 0
				SET @WitRows = 1
		END

		IF @WitRows = 1
		BEGIN
			PRINT 'WITH RECORDS'
			EXECUTE USP_ReceivedIntegrations	@Integration = @Param0, 
												@Company = @Param1, 
												@BatchId = @Param2, 
												@GPServer = @Param3,
												@Status = 0
		END
	END
END