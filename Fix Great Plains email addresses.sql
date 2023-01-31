SELECT	* --RTRIM(EmailCardAddress) AS EmailCardAddress
FROM	SY04906
WHERE	GPCustom.dbo.IsEmailAddressValid(EmailCardAddress) = 0
ORDER BY EmailCardAddress
/*
UPDATE	SY04906
SET		EmailCardAddress = REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(EmailCardAddress)), ' ', ''), '	', ''), ' ', '')
WHERE	GPCustom.dbo.IsEmailAddressValid(EmailCardAddress) = 0
*/
/*
UPDATE	SY04906
SET		EmailCardAddress = 'raj@parikhfinancial.com'
WHERE	EmailCardAddress = ' raj@parikhfinancial.com'
*/