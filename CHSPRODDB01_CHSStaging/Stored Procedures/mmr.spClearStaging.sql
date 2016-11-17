SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	     Travis Parker
-- Create date:	07/28/2016
-- Description:	Clears the MMR staging tables 
-- =============================================
CREATE PROC [mmr].[spClearStaging]
AS
     SET NOCOUNT ON;
     SET XACT_ABORT ON;

     TRUNCATE TABLE mmr.MMR_Stage




GO
