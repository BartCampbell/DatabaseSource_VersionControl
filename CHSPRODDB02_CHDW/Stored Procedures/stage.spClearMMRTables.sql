SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	08/01/2016
-- Description:	truncates the staging tables used for the MOR load
-- Usage:			
--		  EXECUTE stage.spClearMMRTables
-- =============================================
CREATE PROC [stage].[spClearMMRTables]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.Client
	   TRUNCATE TABLE stage.Member
	   TRUNCATE TABLE stage.MemberClient
	   TRUNCATE TABLE stage.MemberHICN
	   TRUNCATE TABLE stage.MMR

    END;     




GO
