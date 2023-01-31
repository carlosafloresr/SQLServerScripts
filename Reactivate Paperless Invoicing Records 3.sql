UPDATE	FSI_ReceivedDetails
SET		RecordStatus = 1
FROM	(
		SELECT	FSI.Company,
				FSI.CustomerNumber,
				FSI.InvoiceNumber,
				FSI.FSI_ReceivedDetailId
		FROM	View_Integration_FSI FSI
				LEFT JOIN PaperlessInvoices PIN ON FSI.Company = PIN.Company AND FSI.CustomerNumber = PIN.Customer AND FSI.InvoiceNumber = PIN.InvoiceNumber
		WHERE	FSI.InvoiceNumber in (
				'C28-180898',
				'69-108390',
				'69-108391',
				'69-108392',
				'69-108393',
				'69-108394',
				'69-108395',
				'69-108396',
				'69-108397',
				'69-108398',
				'69-108399',
				'69-108606',
				'69-108607',
				'69-108608',
				'69-108609',
				'69-108610',
				'69-108611',
				'69-108612',
				'69-108613',
				'69-108614',
				'69-108615',
				'69-108616',
				'69-108617',
				'69-108618',
				'69-108619',
				'69-108620',
				'69-108621',
				'69-108622',
				'69-108623',
				'69-108624',
				'69-108625',
				'69-108626',
				'69-108627',
				'69-108628',
				'69-108629',
				'69-108630',
				'69-108631',
				'69-108632',
				'69-108633',
				'26-272004',
				'34-220443',
				'34-220448',
				'34-220449',
				'34-220450',
				'34-220451',
				'34-220494',
				'34-220495',
				'34-220496',
				'34-220238',
				'34-220239',
				'34-219464',
				'34-219748',
				'28-181501',
				'28-181501',
				'28-181302',
				'28-181298',
				'66-111180',
				'66-110893',
				'26-271785',
				'26-271851',
				'26-272091',
				'26-272092',
				'26-272093',
				'26-272094',
				'26-272095',
				'26-272096',
				'26-272097',
				'26-272099',
				'26-272100',
				'26-272101',
				'26-272102',
				'26-272103',
				'26-272104',
				'26-272105',
				'28-181276',
				'28-181289',
				'34-219872',
				'34-220542',
				'34-220528',
				'34-220532',
				'34-220533',
				'34-220534',
				'34-220231',
				'69-108295',
				'69-108297',
				'69-108298',
				'69-108300',
				'69-108301',
				'69-108793',
				'69-108795',
				'69-108796',
				'69-108335',
				'36-185224',
				'34-219803',
				'35-145144',
				'35-145270',
				'35-145271',
				'35-145272',
				'35-145286',
				'35-145355',
				'35-145358',
				'35-145371',
				'35-145372',
				'35-145374',
				'35-145375',
				'35-145383',
				'35-145395',
				'35-145396',
				'35-145405',
				'35-145418',
				'26-272025',
				'26-272026',
				'34-220102',
				'26-271873',
				'66-111208',
				'CD28-175371C',
				'36-185011',
				'36-185076')
		) DATA
WHERE	FSI_ReceivedDetails.FSI_ReceivedDetailId = DATA.FSI_ReceivedDetailId

DELETE	PaperlessInvoices
FROM	(
		SELECT	FSI.Company,
				FSI.CustomerNumber,
				FSI.InvoiceNumber,
				FSI.FSI_ReceivedDetailId
		FROM	View_Integration_FSI FSI
				LEFT JOIN PaperlessInvoices PIN ON FSI.Company = PIN.Company AND FSI.CustomerNumber = PIN.Customer AND FSI.InvoiceNumber = PIN.InvoiceNumber
		WHERE	FSI.InvoiceNumber in (
				'C28-180898',
				'69-108390',
				'69-108391',
				'69-108392',
				'69-108393',
				'69-108394',
				'69-108395',
				'69-108396',
				'69-108397',
				'69-108398',
				'69-108399',
				'69-108606',
				'69-108607',
				'69-108608',
				'69-108609',
				'69-108610',
				'69-108611',
				'69-108612',
				'69-108613',
				'69-108614',
				'69-108615',
				'69-108616',
				'69-108617',
				'69-108618',
				'69-108619',
				'69-108620',
				'69-108621',
				'69-108622',
				'69-108623',
				'69-108624',
				'69-108625',
				'69-108626',
				'69-108627',
				'69-108628',
				'69-108629',
				'69-108630',
				'69-108631',
				'69-108632',
				'69-108633',
				'26-272004',
				'34-220443',
				'34-220448',
				'34-220449',
				'34-220450',
				'34-220451',
				'34-220494',
				'34-220495',
				'34-220496',
				'34-220238',
				'34-220239',
				'34-219464',
				'34-219748',
				'28-181501',
				'28-181501',
				'28-181302',
				'28-181298',
				'66-111180',
				'66-110893',
				'26-271785',
				'26-271851',
				'26-272091',
				'26-272092',
				'26-272093',
				'26-272094',
				'26-272095',
				'26-272096',
				'26-272097',
				'26-272099',
				'26-272100',
				'26-272101',
				'26-272102',
				'26-272103',
				'26-272104',
				'26-272105',
				'28-181276',
				'28-181289',
				'34-219872',
				'34-220542',
				'34-220528',
				'34-220532',
				'34-220533',
				'34-220534',
				'34-220231',
				'69-108295',
				'69-108297',
				'69-108298',
				'69-108300',
				'69-108301',
				'69-108793',
				'69-108795',
				'69-108796',
				'69-108335',
				'36-185224',
				'34-219803',
				'35-145144',
				'35-145270',
				'35-145271',
				'35-145272',
				'35-145286',
				'35-145355',
				'35-145358',
				'35-145371',
				'35-145372',
				'35-145374',
				'35-145375',
				'35-145383',
				'35-145395',
				'35-145396',
				'35-145405',
				'35-145418',
				'26-272025',
				'26-272026',
				'34-220102',
				'26-271873',
				'66-111208',
				'CD28-175371C',
				'36-185011',
				'36-185076')
		) DATA
WHERE	PaperlessInvoices.Company = DATA.Company
		AND PaperlessInvoices.Customer = DATA.CustomerNumber
		AND PaperlessInvoices.InvoiceNumber = DATA.InvoiceNumber