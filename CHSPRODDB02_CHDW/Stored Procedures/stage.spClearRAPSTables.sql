SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	truncates the staging tables used for the RAPS Response load
-- Usage:			
--		  EXECUTE stage.spClearRAPSTables
-- =============================================
CREATE PROC [stage].[spClearRAPSTables]
AS

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.RAPSResponse
	   TRUNCATE TABLE stage.Member_RAPS
	   TRUNCATE TABLE stage.MemberClient_RAPS
	   TRUNCATE TABLE stage.MemberHICN_RAPS
	   TRUNCATE TABLE stage.Client_RAPS

    END;     



GO
