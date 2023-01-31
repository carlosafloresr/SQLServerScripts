/*
*************************************************************
*      COPY CODE RELATIONS FROM ONE LOCATION TO OTHER       *
*************************************************************
*/

DECLARE	@OldLocation	Varchar(20), -- Copy From
		@NewLocation	Varchar(20)  -- Copy To

SET		@OldLocation	= 'MEMPHIS'
SET		@NewLocation	= 'EL PASO'

INSERT INTO CodeRelations
SELECT	RelationType
		,CASE WHEN RelationType IN ('JC','CA') THEN @NewLocation ELSE ParentCode END ParentCode
		,ChildCode
		,Category
		,SubCategory
		,@NewLocation AS Location
FROM	CodeRelations
WHERE	Location = @OldLocation
ORDER BY
		RelationType
		,ParentCode
		,ChildCode