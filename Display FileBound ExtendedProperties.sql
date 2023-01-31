SELECT	* 
FROM	ExtendedProperties 
WHERE	ObjectID IN (SELECT FileID FROM View_DEXDocuments WHERE ProjectID = 65 AND Field4 = '1804825')
ORDER BY ExtendedPropertyID