/****** Script for SelectTopNRows command from SSMS  ******/
  UPDATE	OOS_Deductions
  SET		DeductionAmount = 100
  WHERE		Fk_OOS_DeductionTypeId IN (SELECT OOS_DeductionTypeId FROM OOS_DeductionTypes WHERE Company = 'IMC' AND DeductionCode = 'CESC')