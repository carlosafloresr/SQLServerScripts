DECLARE	@ProjectId	Int = 66,
		@Field4		Varchar(20) = '336803'

SELECT	*
FROM	View_DEXDocuments
WHERE	ProjectID = @ProjectId
		AND Field4 = @Field4

/*
DELETE Documents WHERE DocumentId In (284022)
DELETE Files WHERE FileId in (189432)
DELETE ExtendedProperties WHERE PropertyKey = 'GL_Code_Entry' AND objectid IN (189432)
*/