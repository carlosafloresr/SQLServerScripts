/*
EXECUTE USP_GP_AR_OpenBalances_Result 'AIS', '14000'
EXECUTE USP_GP_AR_OpenBalances_Result 'AIS', '25000'
*/
ALTER PROCEDURE USP_GP_AR_OpenBalances_Result
		@CompanyId		Varchar(5),
		@CustomerId		Varchar(15)
AS
SELECT	Company,
		RTRIM(Company) + ' - ' + CompanyName AS CompanyName,
		CustomerId + ' - ' + CustomerName AS Customer,
		CASE WHEN NationalId IS Null OR NationalId = CustomerId OR NationalId = '' THEN '' ELSE NationalId + ' - ' + NationalName END AS MainGroup,
		DocumentNumber,
		DocumentDate,
		DueDate,
		PostDate,
		DocumentAmount,
		Balance,
		Description,
		Reference,
		PayTerm,
		Trailer,
		Chassis,
		CompanyId,
		UserId
FROM	GP_AR_OpenBalances
WHERE	CompanyId = @CompanyId 
		AND (CustomerId = @CustomerId
		OR NationalId = @CustomerId)
ORDER BY
		CustomerId,
		DocumentDate,
		DocumentNumber