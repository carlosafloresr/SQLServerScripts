--SELECT	Field8 AS VendorId,
--		Field1 AS VendorName,
--		Field1 AS Invoice,
--		Field6 AS Approver,
--		* --UserId
--FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments
--WHERE	Field4 IN ('292725','290521','85-107821')
--		--AND fINISHED = 1

DECLARE @Invoice Varchar(30) = 'RRTESTINV'

SELECT	*
FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments
WHERE	fileid = 4088530
		--Field4 IN (@Invoice) 
		--AND PROJECTID = 144

select	*
from	PRIFBSQL01P.FB.dbo.ExtendedProperties
where	objectid = 4088530
		--and propertykey = 'GL_Code_Entry'
--in (SELECT	fileid
--FROM	PRIFBSQL01P.FB.dbo.View_DEXDocuments
--WHERE	Field4 IN (@Invoice) AND PROJECTID = 144)
		and propertykey = 'GL_Code_Entry'