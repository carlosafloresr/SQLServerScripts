select pm1.VENDORID, pm2.VENDNAME, SUM(docamnt) as amount from PM30200 pm1 inner join PM00200 pm2 on pm1.VENDORID = pm2.VENDORID
where pm1.DOCTYPE = 1 and pm1.POSTEDDT between '1/2/2011' and '12/31/2011' group by pm1.VENDORID, pm2.VENDNAME
union
select pm1.VENDORID, pm2.VENDNAME, SUM(docamnt) as amount from PM20000 pm1 inner join PM00200 pm2 on pm1.VENDORID = pm2.VENDORID
where pm1.DOCTYPE = 1 and pm1.POSTEDDT between '1/2/2011' and '12/31/2011' group by pm1.VENDORID, pm2.VENDNAME




