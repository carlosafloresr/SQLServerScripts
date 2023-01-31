SET NOCOUNT ON

DECLARE @tblData Table (Reference Varchar(50))

INSERT INTO @tblData (Reference) VALUES ('ICB|95-158491-8-662815')
INSERT INTO @tblData (Reference) VALUES ('ICB|95-159168|57-193887')
INSERT INTO @tblData (Reference) VALUES ('ICB:95-162061|08-667617')
INSERT INTO @tblData (Reference) VALUES ('ICB|95-168620|08-676373')
INSERT INTO @tblData (Reference) VALUES ('ICB:96-109763|54-116568')
INSERT INTO @tblData (Reference) VALUES ('ICB:96-109764|54-116569')
INSERT INTO @tblData (Reference) VALUES ('ICB|96-114746|57-115490')
INSERT INTO @tblData (Reference) VALUES ('ICB|96-114746|57-115490')
INSERT INTO @tblData (Reference) VALUES ('ICB|96-116381|57-117164')
INSERT INTO @tblData (Reference) VALUES ('ICB:C97-106250|57-171036')
INSERT INTO @tblData (Reference) VALUES ('ICB:D97-107527|70-100020')
INSERT INTO @tblData (Reference) VALUES ('ICB:97-108674|95-101645')
INSERT INTO @tblData (Reference) VALUES ('ICB|97-111586|55-150891')
INSERT INTO @tblData (Reference) VALUES ('ICB|55-150891|97-111586')
INSERT INTO @tblData (Reference) VALUES ('ICB|95-170623|57-117275')
INSERT INTO @tblData (Reference) VALUES ('ICB|96-116703|34-241557')

SELECT	*
FROM	Integrations_GL
WHERE	Refrence IN (
SELECT	'ICB|' + 
		SUBSTRING(Reference, dbo.AT('|', Reference, 2) + 1, 10) + '|' +
		REPLACE(SUBSTRING(Reference, dbo.AT('|', Reference, 1) + 1, 10), '|', '')
FROM	@tblData)

/*
UPDATE	Integrations_GL
SET		Processed = 0
WHERE	Refrence IN (
SELECT	'ICB|' + 
		SUBSTRING(Reference, dbo.AT('|', Reference, 2) + 1, 10) + '|' +
		REPLACE(SUBSTRING(Reference, dbo.AT('|', Reference, 1) + 1, 10), '|', '')
FROM	@tblData)
*/