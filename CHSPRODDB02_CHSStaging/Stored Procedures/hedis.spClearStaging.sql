SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Clears the HEDIS staging table
-- =============================================
CREATE PROC [hedis].[spClearStaging]
AS
     SET NOCOUNT ON;

     TRUNCATE TABLE hedis.RawImport

GO
