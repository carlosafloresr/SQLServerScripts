SELECT * FROM ReceivedIntegrations WHERE STATUS = 0

UPDATE ReceivedIntegrations SET Status = 7 WHERE Integration = 'LCKBX'