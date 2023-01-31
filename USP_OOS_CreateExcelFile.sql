CREATE PROCEDURE USP_OOS_CreateExcelFile
		@Company	Char(6),
		@UserId		Varchar(25),
		@PayDate	Char(10),
		@File		Varchar(100)
AS
DECLARE	@Arguments	Varchar(200)
SET		@Arguments = 'C:\ILSApplications\OOS_PreReport\OOSExcelCreator.EXE ' + RTRIM(@Company) + ' ' + RTRIM(@UserId) + ' ' + RTRIM(@PayDate) + ' ' + RTRIM(@File)

EXECUTE MASTER.dbo.XYRunProc @Arguments, 'C:\ILSApplications\OOS_PreReport\', '', 2

EXECUTE USP_OOS_CreateExcelFile 'AIS', 'CFLORES', '6/19/2008', 'C:\TEMP\tmpCFLORES_06202008.xls'