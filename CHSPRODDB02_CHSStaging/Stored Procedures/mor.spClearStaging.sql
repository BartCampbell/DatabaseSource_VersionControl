SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/26/2016
-- Description:	Clears the MOR staging tables 
-- =============================================
CREATE PROC [mor].[spClearStaging]
AS
     SET NOCOUNT ON;
     SET XACT_ABORT ON;

     TRUNCATE TABLE mor.MOR_ARecord_Stage
	TRUNCATE TABLE mor.MOR_BRecord_Stage
	TRUNCATE TABLE mor.MOR_CRecord_Stage
	TRUNCATE TABLE mor.MOR_Header_Stage
	TRUNCATE TABLE mor.MOR_Trailer_Stage



GO
