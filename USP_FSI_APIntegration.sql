USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_APIntegration]    Script Date: 1/26/2023 2:52:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_APIntegration @Company='OIS', @BatchId='5FSI20200512_1721'
EXECUTE USP_FSI_APIntegration @Company='GLSO', @BatchId='9FSI20230126_1006', @JustCheck=1
*/
ALTER PROCEDURE [dbo].[USP_FSI_APIntegration]
		@Company	Varchar(5), 
		@BatchId	Varchar(25),
		@GPServer	Varchar(50) = Null,
		@JustCheck	Bit = 0
AS
SET NOCOUNT ON

IF dbo.AT('_SUM', @BatchId, 1) = 0
BEGIN
	DECLARE @tblVendors	Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))

	INSERT INTO @tblVendors
	SELECT	Company, 
			VendorId,
			'PP'
	FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
	WHERE	Company = @Company 
			AND PierPassType = 1

	IF EXISTS(SELECT TOP 1 RecordCode FROM FSI_ReceivedSubDetails WHERE BatchId = @BatchId AND RecordType = 'VND' AND VndIntercompany = 0)
	BEGIN
		DECLARE	@Param0	Varchar(10) = 'FSIP',
				@Param1	Varchar(5) = @Company,
				@Param2	Varchar(25) = @BatchId,
				@Param3	Varchar(50) = ISNULL(@GPServer, 'PRISQL01P')

		UPDATE	FSI_ReceivedSubDetails
		SET		FSI_ReceivedSubDetails.Processed = 0
		FROM	(
				SELECT	FSI_ReceivedSubDetailId AS RecordId
				FROM	FSI_ReceivedSubDetails FSI
						LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PA2 ON PA2.Company = @Company AND PA2.ParameterCode = 'DEMURRAGE_ACCCODE' AND FSI.AccCode = PA2.VarC
				WHERE	FSI.BatchId = @BatchId
						AND FSI.RecordType = 'VND'
						AND FSI.PrePay = 0
						AND FSI.ICB = 0
						AND FSI.PrePayType IS Null
						AND FSI.VndIntercompany = 0
						AND ISNULL(FSI.PerDiemType, 0) = 0
						AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors)
						AND PA2.VarC IS NUll
				) DATA
		WHERE	FSI_ReceivedSubDetailId = RecordId

		IF @@ROWCOUNT > 0
		BEGIN
			IF @JustCheck = 0
				EXECUTE USP_ReceivedIntegrations	@Integration = @Param0, 
													@Company = @Param1, 
													@BatchId = @Param2, 
													@GPServer = @Param3
			ELSE
				PRINT 'With AP Transactions'
		END
	END
END

-- SELECT DISTINCT * FROM View_Integration_FSI_Vendors WHERE BatchId = '9FSI20150302_1639' AND Processed = 0 AND VndIntercompany = 0