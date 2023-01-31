ALTER TABLE FSI_ReceivedSubDetails
	ALTER COLUMN FileRowNumber Int

ALTER TABLE FSI_ReceivedSubDetails
	ADD CONSTRAINT [DriverDocuments_FileRowNumber]  DEFAULT ((0)) FOR [FileRowNumber]