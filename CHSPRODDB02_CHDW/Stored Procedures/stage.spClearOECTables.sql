SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	truncates the staging tables used for the OEC load
-- Usage:			
--		  EXECUTE stage.spClearOECTables
-- =============================================
CREATE PROC [stage].[spClearOECTables]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        TRUNCATE TABLE stage.Client
	   TRUNCATE TABLE stage.Member
	   TRUNCATE TABLE stage.MemberClient
	   TRUNCATE TABLE stage.MemberHICN
	   TRUNCATE TABLE stage.Network
	   TRUNCATE TABLE stage.OEC
	   TRUNCATE TABLE stage.OECProject
	   TRUNCATE TABLE stage.Provider
	   TRUNCATE TABLE stage.ProviderClient
	   TRUNCATE TABLE stage.ProviderContact
	   TRUNCATE TABLE stage.ProviderLocation
	   TRUNCATE TABLE stage.ProviderSpecialty
	   TRUNCATE TABLE stage.Specialty
	   TRUNCATE TABLE stage.Vendor
	   TRUNCATE TABLE stage.VendorContact
	   TRUNCATE TABLE stage.VendorLocation
	   TRUNCATE TABLE stage.MemberHCC_OEC
	   TRUNCATE TABLE stage.OECClaimLineDetail

    END;     


GO
