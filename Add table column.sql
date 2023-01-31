ALTER TABLE GPVendorMaster
ADD EnterpriseNumber Bigint
GO 

ALTER TABLE OOS_Deductions
ADD [Sequence] Smallint NOT NULL
CONSTRAINT OOS_Deductions_Sequence DEFAULT 0
GO

ALTER TABLE RepairsPictures
ADD SavedOn Datetime NULL
GO