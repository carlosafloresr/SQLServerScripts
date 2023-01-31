SELECT	*
FROM	OOS_Deductions
WHERE	Fk_OOS_DeductionTypeId IN (
SELECT	OOS_DeductionTypeId
FROM	OOS_DeductionTypes
WHERE	DeductionCode = 'FUELTAX')