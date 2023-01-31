DECLARE	@Query		Varchar(Max),
		@parType	Char(1) = 'I'

SET @Query = N'SELECT DISTINCT OD.Div_Code, OD.Pro, MV.ADate, MV.Tl_Code, MV.Ch_Code FROM TRK.Move MV INNER JOIN TRK.Order OD ON MV.Or_No = OD.No 
INNER JOIN TRK.LocProf LP ON MV.Cmpy_No = LP.CMPY_NO AND (LP.CODE = MV.OLP_Code OR LP.CODE = MV.DLP_Code) 
WHERE MV.Cmpy_No = 8 AND MV.ADate BETWEEN ''2021-01-02'' AND ''2022-01-17'' AND (MV.Tl_Code = ''CAAU586623'' OR MV.Ch_Code = ''CAUU586623'')'


EXECUTE USP_QuerySWS_ReportData @Query

--SELECT * FROM COMPANIES

--AND LP.Type In (''P'', ''D'', ''R'')