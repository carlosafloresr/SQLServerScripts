IF EXISTS (SELECT Name FROM sys.tables WHERE Name = 'ControlReportSchedule')
     BEGIN
           IF EXISTS (SELECT TOP(1) name FROM sys.symmetric_keys WHERE name = 'GeneralUserSymmetricKey')
                   DROP SYMMETRIC KEY GeneralUserSymmetricKey

          IF EXISTS (SELECT TOP(1) name FROM sys.certificates WHERE name = 'GeneralUserCertificate')
                   DROP CERTIFICATE GeneralUserCertificate

           IF EXISTS (SELECT TOP(1) name FROM sys.symmetric_keys WHERE name = 'ConnectorServiceSymmetricKey')
                   DROP SYMMETRIC KEY ConnectorServiceSymmetricKey

           IF EXISTS (SELECT TOP(1) name FROM sys.certificates WHERE name = 'ConnectorServiceCertificate')    
                   DROP CERTIFICATE ConnectorServiceCertificate

           IF EXISTS (SELECT TOP(1) name FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
                   DROP MASTER KEY

           CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@DGMemphis2010'
           -- NOTE Where Access!23 is your actual password

           CREATE CERTIFICATE [ConnectorServiceCertificate]
                 AUTHORIZATION [dbo]
                 WITH SUBJECT = N'Certificate for symmetric key encryption - for use by the connector service.'

           CREATE CERTIFICATE [GeneralUserCertificate]
                 AUTHORIZATION [dbo]
                 WITH SUBJECT = N'Certificate for access symmetric keys - for use by users assigned to the GeneralUser Role.'

           CREATE SYMMETRIC KEY [ConnectorServiceSymmetricKey]
                 AUTHORIZATION [dbo]
                 WITH ALGORITHM = AES_256
                 ENCRYPTION BY CERTIFICATE [ConnectorServiceCertificate]

           CREATE SYMMETRIC KEY [GeneralUserSymmetricKey]
                 AUTHORIZATION [dbo]
                 WITH ALGORITHM = AES_256
                 ENCRYPTION BY CERTIFICATE [GeneralUserCertificate]

           IF NOT EXISTS(SELECT TOP(1) name FROM sys.database_principals WHERE name='GeneralUser')
                   BEGIN
                       CREATE ROLE [GeneralUser]
                       AUTHORIZATION [dbo]
                   END

           GRANT CONTROL ON CERTIFICATE::[GeneralUserCertificate] TO [GeneralUser]
           GRANT VIEW DEFINITION on SYMMETRIC KEY::[GeneralUserSymmetricKey] TO [GeneralUser]
           GRANT CONTROL ON CERTIFICATE::[ConnectorServiceCertificate] TO [GeneralUser]
           GRANT VIEW DEFINITION on SYMMETRIC KEY::[ConnectorServiceSymmetricKey] TO [GeneralUser]
           UPDATE Connector.Adapter
           SET Settings.modify('declare namespace x="http://www.microsoft.com/2009/Dynamics/Integration";
                                 replace value of
                                 (/SettingsCollection/x:ArrayOfSettingsValue/x:SettingsValue[x:Attributes="Password"]/x:Value/text())[1]
                                 with ""')
           UPDATE Connector.MapCategoryAdapterSettings
           SET Settings.modify('declare namespace x="http://www.microsoft.com/2009/Dynamics/Integration";
                                 replace value of                              
(/SettingsCollection/x:ArrayOfSettingsValue/x:SettingsValue[x:Attributes="Password"]/x:Value/text())[1]
                                 with ""')
     END
ELSE
     BEGIN
           PRINT 'WARNING: Incorrect database selected.'
           Print 'Execute script against the Management Reporter 2012 database.'
           PRINT 'This can be found in the Management Reporter 2012 Configuration Console.'
     END