ALTER DATABASE Integrations SET TRUSTWORTHY ON;

CREATE ASSEMBLY eConnectSerialization 
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn\Microsoft.GreatPlains.eConnect.Serialization.dll'
WITH PERMISSION_SET = UNSAFE;

CREATE ASSEMBLY eConnect
FROM 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn\Microsoft.GreatPlains.eConnect.dll'
WITH PERMISSION_SET = UNSAFE;