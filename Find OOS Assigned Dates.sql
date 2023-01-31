SELECT	Equipment, CustomerNumber, MAX(creationDate) as creationDate, Mechanic
FROM	Repairs
WHERE	Equipment IN ('COZZ24637',
'DFLZ401847',
'EMCZ220299',
'EMCZ220429',
'EMCZ246011',
'EMCZ520298',
'EMCZ540355',
'EMCZ540668',
'EMCZ820265',
'FLXZ439272',
'FLXZ442758',
'FVXZ178946',
'FVXZ707338',
'FVXZ709352',
'GCEZ425194',
'HDMZ203103',
'HDMZ203946',
'HDMZ406489',
'HJCZ120432',
'HJCZ142698',
'HLC707970',
'HLC784622',
'HLC802994',
'HLC840200',
'HLC845361',
'HLC845597',
'IMCZ027434',
'IMCZ23607',
'IMCZ25047',
'IMCZ25056',
'IMCZ45787',
'IMCZ520825',
'KKLZ165003',
'KKLZ165253',
'KKLZ200852',
'KKLZ408914',
'KKLZ450674',
'MATZ902552',
'MOFZ650447',
'MOLA530843',
'NYKZ415185',
'NYKZ437958',
'OOLZ48169',
'TAXZ139048',
'TAXZ139068',
'TAXZ142481',
'TAXZ190520',
'TAXZ612474',
'TLXZ208904',
'TLXZ217324',
'TLXZ266862',
'TLXZ296855',
'TLXZ422434',
'TLXZ429869',
'TLXZ461396',
'TLXZ461564',
'TLXZ524241',
'TMEZ208084',
'TMEZ295991',
'TMEZ434340',
'TMEZ625783',
'TRLZ200821',
'TRLZ450334',
'TRZZ409282',
'YMLZ402689',
'YMLZ424464',
'YMLZ426106',
'ZCSD031984',
'ZCSD032290',
'ZCSZ503788'
					 )
AND YEAR(CreationDate) > 2012
GROUP BY Equipment, CustomerNumber, Mechanic
ORDER BY 1