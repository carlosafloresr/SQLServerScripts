--select * from UPR40500 where ACTINDX not in (select ACTINDX from GL00105) 

select * from UPR40500 where ACTINDX in (select ACTINDX from UPR40500 where ACTINDX not in (select ACTINDX from GL00105) )