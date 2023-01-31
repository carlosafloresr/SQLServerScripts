DECLARE @Query Varchar(MAX)

SET @Query =  N'SELECT DISTINCT OD.Div_Code, OD.Pro, MV.ADate FROM TRK.Move MV INNER JOIN TRK.Order OD ON MV.Or_No = OD.No 
INNER JOIN TRK.LocProf LP ON MV.Cmpy_No = LP.CMPY_NO AND LP.CODE = MV.DLP_Code AND LP.Type In (''P'', ''D'', ''R'') 
WHERE MV.Cmpy_No = 8 
 AND MV.ADate BETWEEN ''03/20/2022'' AND ''04/13/2022'' 
 AND MV.Tl_Code = ''APHU732706'''

 EXECUTE USP_QuerySWS_ReportData @Query

 
 