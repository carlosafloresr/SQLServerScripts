SELECT * FROM UPR30300 where employid = 202 and payrolcd = 'HOUR' -- and auctrlcd = 'UPRCC00000349' 

SELECT * FROM UPR30301 where year1 = 2010 order by employid, payrolcd
SELECT * FROM rcmr_restore..UPR30301 where year1 = 2010 order by employid, payrolcd
/*
--DELETE UPR30301 WHERE employid in (SELECT employid FROM UPR30300 where auctrlcd = 'UPRCC00000349') and year1 = 2010
delete UPR30100 where AUCTRLCD='UPRCC00000351' 
delete UPR30200 where AUCTRLCD='UPRCC00000351' 
delete UPR30300 where AUCTRLCD='UPRCC00000351' 
delete UPR30400 where AUCTRLCD='UPRVC00000043' 
delete UPR30401 where AUCTRLCD='UPRVC00000043'

UPDATE	UPR30301 
SET		MTDWAGES_7 = RECS.MTDWAGES_7
FROM	(SELECT * FROM rcmr_restore..UPR30301 where year1 = 2010) RECS
WHERE	UPR30301.year1 = 2010 
		AND UPR30301.employid = RECS.employid
		AND UPR30301.payrolcd = RECS.payrolcd

*/