USE [FI_Data]
GO
/****** Object:  StoredProcedure [dbo].[USP_CodeRelations_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_CodeRelations_TimeStamp] 
		@Location	Varchar(30),
		@TimeStamp	Datetime
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	CodeRelations
WHERE	(@Location IS Null OR (@Location IS NOT Null AND Location = @Location))
		AND TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Customers_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Customers_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Customers
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_DamageCodes_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_DamageCodes_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	DamageCodes
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Depots_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_Depots_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Depots
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_EquipmentSize_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_EquipmentSize_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	EquipmentSize
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_JobCodes_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_JobCodes_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	JobCodes
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Locations_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Locations_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Locations
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Mech_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_Mech_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Mech
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Positions_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Positions_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Positions
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_RepairCodes_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_RepairCodes_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	RepairCodes
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_SubCategories_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_SubCategories_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	SubCategories
WHERE	TimeStamp > @TimeStamp


RETURN @Counter
GO
/****** Object:  StoredProcedure [dbo].[USP_Translation_TimeStamp]    Script Date: 12/07/2012 12:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_Translation_TimeStamp] (@TimeStamp Datetime)
AS
DECLARE	@Counter	Int

SELECT	@Counter = COUNT(*)
FROM	Translation
WHERE	TimeStamp > @TimeStamp

RETURN @Counter
GO
