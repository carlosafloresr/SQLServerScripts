SELECT * FROM PM30600 WHERE VCHRNMBR in ('00000000000000048','00000000000000049','00000000000000050')
SELECT * FROM PM30200 WHERE VCHRNMBR = '00000000000005635'

UPDATE PM30600 SET DistRef = 'AJ''s Mobil-Wash Fuel Island' WHERE VCHRNMBR ='00000000000000050'

SELECT * FROM GL20000 WHERE DebitAmt = 136.56 --  JRNENTRY IN (243,244)

UPDATE GL20000 SET Dscriptn = Refrence WHERE JRNENTRY IN (13661)