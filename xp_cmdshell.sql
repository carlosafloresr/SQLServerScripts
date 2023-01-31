USE master;

GRANT EXECUTE ON xp_cmdshell TO [IILOGISTICS\bcatt]

EXEC sp_xp_cmdshell_proxy_account 'IILOGISTICS\bcatt', 'pwd'

GRANT CONTROL SERVER TO [IILOGISTICS\bcatt]
GO