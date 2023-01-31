SELECT	VCL.AccountingId
		,VCL.GL_Claim_Number
		,SUM(CLD.dir_pay_reserve + CLD.deduct_reserve) AS Reserve
		,SUM(CLD.dir_pay_reserve + CLD.dir_pay_paid + CLD.dir_pay_expense + CLD.deduct_reserve + CLD.deduct_sir_paid + CLD.deduct_hf + CLD.deduct_alae) AS [total_incurred]
		,SUM((CLD.dir_pay_reserve + CLD.dir_pay_paid + CLD.dir_pay_expense + CLD.deduct_reserve + CLD.deduct_sir_paid + CLD.deduct_hf + CLD.deduct_alae)-(CLD.dir_pay_reserve + CLD.deduct_reserve)) AS Paid
		--,CLD.*
FROM	Claim_Master CLM
		INNER JOIN View_Claim_Identifiers VCL ON CLM.client = VCL.Client AND CLM.claim_year = VCL.Claim_Year AND CLM.claim_id = VCL.Claim_Id
		LEFT JOIN Claim_Detail CLD ON CLM.client = CLD.client AND CLM.Claim_Year = CLD.Claim_Year AND CLM.Claim_Id = CLD.Claim_Id 
		LEFT OUTER JOIN event_type EVT ON CLM.event_type = EVT.ID
		LEFT OUTER JOIN incident_codes INC ON CLM.incident_code = INC.ID
WHERE	--CLD.dir_pay_reserve + CLD.deduct_reserve > 0
		VCL.AccountingId = 'NDS19001'
GROUP BY 
		VCL.AccountingId
		,VCL.GL_Claim_Number
ORDER BY
		VCL.AccountingId