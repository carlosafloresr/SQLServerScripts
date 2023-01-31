CREATE VIEW View_FI_Estimates
AS
SELECT	HDR.Id
		,HDR.inv_no
		,HDR.acct_no
		,HDR.container
		,HDR.chassis
		,HDR.cost
		,HDR.vendor_id
		,HDR.genset_no
		,HDR.post_date
		,CASE WHEN FullFileName IS Null THEN RTRIM(HDR.genset_no) ELSE '<a target="_blank" href="' + FullFileName + '"><p style="font-size: 8pt;">' + RTRIM(HDR.genset_no) + '</p></a>' END AS GenSetDisplay
		,DET.Id AS DetailId
		,DET.EstimateId
		,DET.status
		,DET.posted
		,DET.inv_est
		,DET.inv_total
		,DET.labor_hour
		,DET.labor
		,DET.mech_hours
		,DET.parts
		,DET.cdex_remk
		,DET.inv_date
		,DET.expire_date
		,DET.week_end
		,DET.entry_date
		,DET.rep_date
		,DET.est_date
		,DET.import_date
		,DET.historical
		,DET.ReceivedOn
FROM	FI_Estimates HDR
		INNER JOIN FI_EstimatesDetails DET ON HDR.Id = DET.EstimateId
		LEFT JOIN (SELECT Field11 AS ProNumber, MAX(FullFileName) AS FullFileName FROM [LENSADEX001\INDEXDATAFILES].FB.dbo.View_DEXDocuments WHERE ProjectId = 107 AND Status = 1 AND Field11 <> '' AND SortOrder = 1 GROUP BY Field11) DEX ON HDR.genset_no = DEX.ProNumber
WHERE	HDR.post_date IS Null



