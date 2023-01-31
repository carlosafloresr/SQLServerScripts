/*
EXECUTE USP_Customer_Verification 'PTS', 'CMACGM'
*/
CREATE PROCEDURE USP_Customer_Verification
		@Company	Varchar(5),
		@Customer	Varchar(15)
AS
SELECT	CASE WHEN SWSCustomerId = @Customer THEN SWSCustomerId ELSE CustNmbr END AS CustomerId,
		CustNmbr, 
		Inactive 
FROM	CustomerMaster 
WHERE	CompanyId = @Company
		AND (CustNmbr = @Customer
		OR SWSCustomerId = @Customer)