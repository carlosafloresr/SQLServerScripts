update	files
set		field1 = texto
from
(
select	* --fileid, documentid, cast(cast(right(rtrim(Field1), 5) as Int) as varchar) as texto
from	View_DEXDocuments
where	ProjectID = 109
		--and field1 = '648'
) dat
where	files.fileid = dat.FileID