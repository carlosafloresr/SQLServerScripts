/*
select	*
from	gl00100
where	ACTINDX in (select ACTINDX from gl00105 where ACTNUMST = '1-28-6000')
*/

UPDATE	gl00100
SET		UsrDefS1 = UserDef1, 
		UserDef1 = ''
WHERE	Userdef1 <> ''