EXECUTE('SELECT * FROM OPENQUERY(PostgreSQLProd, ''SELECT * FROM GPS.DPY WHERE GPS_TimeStamp IS Null'')')