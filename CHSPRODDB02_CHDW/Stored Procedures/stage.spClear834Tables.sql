SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/11/2016
-- Description:	truncates the staging tables used for the 834 load
-- Usage:			
--		  EXECUTE stage.spClear834Tables
-- =============================================
CREATE PROC [stage].[spClear834Tables]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.Client
	   TRUNCATE TABLE stage.Member
	   TRUNCATE TABLE stage.MemberClient
	   TRUNCATE TABLE stage.MemberEligibility
	   TRUNCATE TABLE stage.MemberHICN
	   TRUNCATE TABLE stage.Network
	   TRUNCATE TABLE stage.Provider
	   TRUNCATE TABLE stage.ProviderClient
	   TRUNCATE TABLE stage.MemberContact
	   TRUNCATE TABLE stage.MemberLocation
	   TRUNCATE TABLE stage.MemberPCP

    END;     



GO
