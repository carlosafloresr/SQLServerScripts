/*
EXECUTE sp_addextendedproc 'SerializeAR','econnectSerializeAR.dll'
EXECUTE sp_dropextendedproc 'SerializeAR'
*/
EXECUTE SerializeAR 'AIS', '4FSI081018_10172008_1251'

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO
