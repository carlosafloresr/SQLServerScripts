select vendorid,
		deductioncode,
		count(deductioncode) as counter
from (
SELECT	* 
FROM	update View_OOS_Transactions set processed= 0 WHERE Company = 'DNJ' AND Period = 'W201038') recs
group by vendorid,
		deductioncode
--order by vendorid, deductioncode

select * from delete oos_transactions where oos_transactionid = 292555

1-11-6181

SELECT	* 
FROM	View_OOS_Transactions 
WHERE	Company = 'DNJ' 
		AND Period = 'W201038'
		and vendorid = 'D0012'
		
		update View_OOS_Transactions set processed= 0 WHERE Company = 'DNJ' AND Period = 'W201038'