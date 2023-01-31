/*

*/
--CREATE PROCEDURE USP_GP_CheckNumberValid

DECLARE @Company		Varchar(5) = 'AIS',
		@Voucher		Varchar(30) = '00000000219335',
		@CheckNum		Varchar(50) = 'EFT000000007624'

SET NOCOUNT ON

DECLARE @IsValid		Bit

DECLARE	@tblCheckVrfy	Table (CheckNumber Varchar(30))

INSERT INTO @tblCheckVrfy
SELECT	DOCNUMBR
FROM	PM00400
WHERE	DOCNUMBR = @CheckNum
		AND CNTRLNUM <> @Voucher

SET @IsValid = IIF((SELECT COUNT(*) FROM @tblCheckVrfy) > 0, 0, 1)

SELECT @IsValid AS IsValid