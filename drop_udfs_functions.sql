IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[AT]') )
    DROP FUNCTION [dbo].[AT]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[RAT]') )
    DROP FUNCTION [dbo].[RAT]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[AT2]') )
    DROP FUNCTION [dbo].[AT2]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ATC]') )
    DROP FUNCTION [dbo].[ATC]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[RATC]') )
    DROP FUNCTION [dbo].[RATC]    
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ATC2]') )
    DROP FUNCTION [dbo].[ATC2]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[PADC]') )
    DROP FUNCTION [dbo].[PADC]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[PADL]') )
    DROP FUNCTION [dbo].[PADL]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[PADR]') )
    DROP FUNCTION [dbo].[PADR]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[STRTRAN]') )
    DROP FUNCTION [dbo].[STRTRAN]    
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[CHRTRAN]') )
    DROP FUNCTION [dbo].[CHRTRAN]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[STRFILTER]') )
    DROP FUNCTION [dbo].[STRFILTER]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[OCCURS]') )
    DROP FUNCTION [dbo].[OCCURS]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[OCCURS2]') )
    DROP FUNCTION [dbo].[OCCURS2]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[PROPER]') )
    DROP FUNCTION [dbo].[PROPER]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[GETWORDCOUNT]') )
    DROP FUNCTION [dbo].[GETWORDCOUNT]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[GETWORDNUM]') )
    DROP FUNCTION [dbo].[GETWORDNUM]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[GETALLWORDS]') )
    DROP FUNCTION [dbo].[GETALLWORDS]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[GETALLWORDS2]') )
    DROP FUNCTION [dbo].[GETALLWORDS2]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[RCHARINDEX]') )
    DROP FUNCTION [dbo].[RCHARINDEX]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[CHARINDEX_BIN]') )
    DROP FUNCTION [dbo].[CHARINDEX_BIN]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[CHARINDEX_CI]') )
    DROP FUNCTION [dbo].[CHARINDEX_CI]    
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ARABTOROMAN]') )
    DROP FUNCTION [dbo].[ARABTOROMAN]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ROMANTOARAB]') )
    DROP FUNCTION [dbo].[ROMANTOARAB]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ADDROMANNUMBERS]') )
    DROP FUNCTION [dbo].[ADDROMANNUMBERS]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ARABTOARMENIAN]') )
    DROP FUNCTION [dbo].[ARABTOARMENIAN]
IF EXISTS (select 1 from   dbo.sysobjects where  id = object_id('[dbo].[ARMENIANTOARAB]') )
    DROP FUNCTION [dbo].[ARMENIANTOARAB]

GO
