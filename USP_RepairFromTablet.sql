CREATE PROCEDURE USP_RepairFromTablet (@DataTable AS tblRepairs READONLY)
AS
SELECT	*
FROM	@DataTable
/*
CREATE TYPE tblRepairs AS TABLE
  (     [Tablet] [varchar](15) NOT NULL,               
        [Consecutive] [int] NOT NULL,
		[WorkOrder] [varchar](12) NOT NULL,
		[InvoiceNumber] [int] NULL,
		[CustomerNumber] [varchar](50) NULL,
		[Equipment] [varchar](15) NULL,
		[EquipmentType] [char](1) NULL,
		[EquipmentSize] [char](6) NULL,
		[EquipmentLocation] [varchar](25) NULL,
		[SubLocation] [varchar](40) NULL,
		[RepairRemarks] [varchar](200) NULL,
		[EstimateDate] [datetime] NULL,
		[RepairDate] [datetime] NULL,
		[Estimator] [varchar](30) NULL,
		[Mechanic] [varchar](20) NULL,
		[PrivateRemarks] [varchar](200) NULL,
		[SerialNumber] [varchar](30) NULL,
		[ModelNumber] [varchar](25) NULL,
		[Hours] [numeric](8, 2) NULL,
		[Manufactor] [varchar](20) NULL,
		[ManufactorDate] [date] NULL,
		[RepairStatus] [char](2) NOT NULL,
		[ChassisInspection] [bit] NOT NULL,
		[ForSubmitting] [bit] NOT NULL,
		[CreationDate] [datetime] NOT NULL,
		[ModificationDate] [datetime] NOT NULL
  )
  */