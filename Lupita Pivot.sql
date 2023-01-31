DECLARE	@Company	Varchar(6),
		@UserId		Varchar(25),
		@Date		Datetime

SET		@Company	= 'IMC'
SET		@UserId		= 'CFLORES'
SET		@Date		= '7/1/2009'

DECLARE @CatPVT		Varchar(MAX), 
		@ColumnCode Varchar(20),
		@CatID		Int

SET		@CatPVT = N''

DECLARE Descripciones CURSOR LOCAL KEYSET OPTIMISTIC FOR

SELECT DISTINCT ColumnCode FROM dbo.OOS_PreReport_Columns WHERE Company = 'IMC' AND UserId = 'CFLORES' ORDER BY ColumnCode
OPEN Descripciones
FETCH FROM Descripciones INTO @ColumnCode

WHILE @@FETCH_STATUS = 0 
BEGIN
 SET @CatPVT = @CatPVT + N',[' + RTRIM(@ColumnCode) + N']'
 FETCH FROM Descripciones INTO @ColumnCode
END

CLOSE Descripciones
DEALLOCATE Descripciones

SET	@CatPVT = SUBSTRING(@CatPVT, 2, LEN(@CatPVT))

DECLARE @Query AS nvarchar(MAX)
SET @Query = N'SELECT * FROM (SELECT DISTINCT OD.DeductionTypeId,
		OD.DeductionCode,
		OD.VendorId,
		VE.VendName AS VendorName,
		CASE WHEN VM.SubType = 2 THEN ''Y'' ELSE '''' END AS MyTruck,
		VM.HireDate,
		VM.TerminationDate,
		OD.AmountToDeduct
FROM	IMC.dbo.PM00200 VE
		LEFT JOIN View_OOS_Deductions OD ON VE.VendorId = OD.VendorId
		LEFT JOIN VendorMaster VM ON VE.VendorId = VM.VendorId AND VM.Company = ''' + @Company + '''
WHERE	OD.Company = ''' + @Company + '''
		AND OD.DedTypeInactive = 0
		AND OD.DeductionInactive = 0
		AND OD.StartDate <= ''' + CONVERT(Char(10), @Date, 101) + '''
		AND ((OD.NumberOfDeductions > 0 AND OD.DeductionNumber < OD.NumberOfDeductions) OR OD.NumberOfDeductions = 0)
		AND ((OD.MaxDeduction > 0 AND CASE WHEN OD.EscrowBalance = 1 THEN OD.Balance ELSE OD.Deducted END < OD.MaxDeduction) OR OD.MaxDeduction = 0)
		AND OD.DeductionCode <> ''MANT'') PIV          
   PIVOT (COUNT(DeductionCode) FOR Descripcion IN ('+ @CatPVT  + ')) AS Child ORDER BY VendorId'
PRINT @Query

EXEC sp_executesql @Query
/*


EXECUTE crosstab 'select mes,PoaCuenta,sum(Cantidad) from [05_Egresos]..Vista_Solicitud_Seg_Gana group by mes,poacuenta',
'SUM(Cantidad)','mes','[05_Egresos]..Vista_Solicitud_Seg_Gana'

*/