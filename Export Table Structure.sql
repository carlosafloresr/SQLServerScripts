SELECT	column_name AS 'Column Name'
		,data_type AS 'Data Type'
		,character_maximum_length AS 'Maximum Length'
FROM	information_schema.columns
WHERE	table_name = 'Sale'