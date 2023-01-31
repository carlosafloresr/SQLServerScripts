-- Dexterity Sessions Table
delete S
-- select * 
from tempdb..DEX_SESSION S
where not exists (
 select * from DYNAMICS..ACTIVITY A 
 where S.session_id = A.SQLSESID)

-- Dexterity Locks Table
delete L
-- select *
from tempdb..DEX_LOCK L
where not exists (
 select * from DYNAMICS..ACTIVITY A 
 where L.session_id = A.SQLSESID)

-- Batch_Headers table in each company
exec sp_MSforeachdb
' use ?
if exists ( select INTERID from DYNAMICS..SY01500 D where INTERID = ''?'' )
begin 
 update S set BCHSTTUS = 0, MKDTOPST = 0, USERID = ''''
 -- select *
 from SY00500  S
 where BCHSTTUS in (1,2,3,4,5,6)
 and not exists (
  select * from DYNAMICS..ACTIVITY A 
  JOIN DYNAMICS..SY01500 C ON C.CMPNYNAM = A.CMPNYNAM
  where S.USERID = A.USERID and C.INTERID = db_name()) 
 and exists (
  select * from DYNAMICS..SY00800 B 
  where not exists (
   select * from DYNAMICS..ACTIVITY A 
   where B.USERID = A.USERID and B.CMPNYNAM = A.CMPNYNAM)
  and S.BCHSOURC = B.BCHSOURC and S.BACHNUMB = B.BACHNUMB)
 print ''''
 print ''('' + ltrim(str(@@ROWCOUNT)) + '' row(s) affected) - Database '' + db_name()
end
'

-- SY_Batch_Activity_MSTR table
delete  B 
-- select * 
from DYNAMICS..SY00800 B
where not exists (
 select * from DYNAMICS..ACTIVITY A 
 where B.USERID = A.USERID and B.CMPNYNAM = A.CMPNYNAM)

-- SY_ResourceActivity table
delete  R 
-- select * 
from DYNAMICS..SY00801 R
where not exists (
 select * from DYNAMICS..ACTIVITY A 
 JOIN DYNAMICS..SY01500 C ON C.CMPNYNAM = A.CMPNYNAM
 where R.USERID = A.USERID and R.CMPANYID = C.CMPANYID) 