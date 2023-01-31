/*
DROP ASSEMBLY [ILSIntegrations.XmlSerializers.dll] WITH NO DEPENDENTS
GO
DROP ASSEMBLY [ILSIntegrations] WITH NO DEPENDENTS
GO
DROP ASSEMBLY ILSIntegrationsXML WITH NO DEPENDENTS
GO
CREATE ASSEMBLY ILSIntegrationsXML FROM 'C:\Assemblies\ILSIntegrations.dll'
GO
CREATE ASSEMBLY [ILSIntegrations.XmlSerializers.dll] FROM 'C:\Assemblies\ILSIntegrations.XmlSerializers.dll' WITH permission_set = SAFE
GO

EXECUTE USP_ExecuteBatch 'FSI', 'IMC', '1FSI090217_1451'

SELECT [name] FROM sys.assemblies
*/

SELECT * FROM ReceivedIntegrations WHERE ReceivedOn > GETDATE() - 1