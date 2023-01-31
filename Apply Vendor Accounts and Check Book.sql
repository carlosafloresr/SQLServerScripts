SELECT * FROM PM00200

UPDATE PM00200 SET ChekBkId = 'Regions AP', PMAPINDX = CASE WHEN VndClsId IN ('DRV','DRL','DMS','DTR','DGR','DDD') THEN 204 WHEN VndClsId IN ('OWC','PDM','MS1','MSC','M&R') THEN 205 ELSE 195 END

select * from dynamics.dbo.SY00800  

DELETE Dynamics.dbo.SY00800 WHERE userid = 'tmilewski'

select * from GL00100 where actnumbr_3 = '2000'
-- 2070 = 205
-- 2050 = 204
-- 2000 = 195