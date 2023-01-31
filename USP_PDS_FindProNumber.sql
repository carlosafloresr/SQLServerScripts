/*
EXECUTE USP_PDS_FindProNumber 8, 'O', 'HDMZ411955', 'TCKU622455', '11/17/2022'
*/
ALTER PROCEDURE USP_PDS_FindProNumber
		@CompanyNumber	Int,
		@Type			Char(1),
		@Chassis		Varchar(15) = Null,
		@Container		Varchar(15) = Null,
		@Date			Date
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@Result			Varchar(25)

DECLARE @tblData		Table (Division Varchar(3), Pro Varchar(10))

SET @Query = N'SELECT DISTINCT OD.Div_Code, OD.Pro FROM TRK.Move MV INNER JOIN TRK.Order OD ON MV.Or_No = OD.No '
SET @Query = @Query + 'INNER JOIN TRK.LocProf LP ON MV.Cmpy_No = LP.CMPY_NO AND LP.CODE = MV.' + IIf(@Type = 'I', 'D', 'O') + 'LP_Code AND LP.Type In (''P'', ''D'', ''R'') '
SET @Query = @Query + 'WHERE MV.Cmpy_No = ' + CAST(@CompanyNumber AS Varchar) + ' AND '
SET @Query = @Query + 'MV.ADate BETWEEN ''' + CAST(DATEADD(dd, -30, @Date) AS Varchar) + ''' AND ''' + CAST(@Date AS Varchar) + ''' AND '
SET @Query = @Query + 'MV.Tl_Code = ''' + @Container + ''''

INSERT INTO @tblData
EXECUTE USP_QuerySWS_ReportData @Query

IF (SELECT COUNT(*) FROM @tblData) > 0
	SET @Result = (SELECT Division + '-' + Pro FROM @tblData)
ELSE
	SET @Result = 'Not in SWS'

SELECT @Result AS Result