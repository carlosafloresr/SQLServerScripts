USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_FindDriversWithDocuments]    Script Date: 5/22/2017 11:22:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FindDriversWithDocuments 'IMC', '06/25/2015', '062515DSDRVCK', NULL, NULL, 0
EXECUTE USP_FindDriversWithDocuments 'AIS', '04/13/2017', 'DSDR041317CK', NULL, NULL, 0
*/
ALTER PROCEDURE [dbo].[USP_FindDriversWithDocuments]
		@Company	Varchar(5),
		@CheckDate	Datetime = Null,
		@BatchId	Varchar(500) = Null,
		@VendorId	Varchar(12) = Null,
		@DocTypes	Varchar(50) = Null,
		@PaidCard	Bit = 0
AS
IF @VendorId IS Null
	EXECUTE USP_DriverMaster_EmailAddressUpdate @Company
ELSE
	EXECUTE USP_DriverMaster_EmailAddressUpdate @Company, @VendorId

SELECT	DISTINCT VDD.Company,
		VDD.VendorId,
		VDD.BatchId,
		VMA.EmailAddress,
		VMA.DocumentsByEmail,
		VMA.TerminationDate
FROM	View_DriverDocuments VDD
		INNER JOIN VendorMaster VMA ON VDD.Company = VMA.Company AND VDD.VendorId = VMA.VendorId --AND VMA.EmailAddress IS NOT Null
WHERE	VDD.Company = @Company
		AND VDD.BatchId <> ''
		AND VDD.VendorId <> 'ALL'
		AND (@CheckDate IS Null OR (@CheckDate IS NOT Null AND VDD.WeekEndingDate = @CheckDate))
		AND (@BatchId IS Null OR (@BatchId IS NOT Null AND PATINDEX('%' + RTRIM(VDD.BatchId) + '%', @BatchId) > 0))
		AND (@VendorId IS Null OR (@VendorId IS NOT Null AND VDD.VendorId = @VendorId))
		AND (@DocTypes IS Null OR (@DocTypes IS NOT Null AND PATINDEX('%' + RTRIM(CAST(VDD.Fk_DocumentTypeId AS Char(3))) + '%', @DocTypes) > 0))
		AND (@PaidCard = 0 OR (@PaidCard = 1 AND VDD.PaidByPayCard = 1))
ORDER BY VDD.BatchId, VDD.VendorId