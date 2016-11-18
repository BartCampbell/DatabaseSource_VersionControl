SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	07/29/2016
-- Description:	truncates the staging tables used for the HEDIS load
-- Usage:			
--		  EXECUTE stage.spClearHEDISTables
-- =============================================
CREATE PROC [stage].[spClearHEDISTables]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN

	   TRUNCATE TABLE stage.HEDIS
	   TRUNCATE TABLE stage.Member_HEDIS 
	   TRUNCATE TABLE stage.MemberClient_HEDIS 
	   TRUNCATE TABLE stage.Client_HEDIS 
	   TRUNCATE TABLE stage.Provider_HEDIS 
	   TRUNCATE TABLE stage.ProviderClient_HEDIS
	   TRUNCATE TABLE stage.Network_HEDIS

    END;     





GO
