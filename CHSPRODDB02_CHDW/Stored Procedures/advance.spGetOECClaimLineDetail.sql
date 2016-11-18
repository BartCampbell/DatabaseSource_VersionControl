SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves claim line detail data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECClaimLineDetail '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECClaimLineDetail]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            o.ChaseID ,
            o.ClientMemberID ,
            o.ClaimID ,
            o.ServiceLine ,
            o.RevenueCode ,
            o.ServiceCode ,
            o.ServiceModifierCode ,
            o.BillTypeCode ,
            o.FacilityTypeCode ,
            o.ProviderNPI ,
            o.ProviderLastName ,
            o.ProviderFirstName ,
            o.ProviderSpecialty ,
            o.ProviderAddress ,
            o.ProviderCity ,
            o.ProviderState ,
            o.ProviderZip ,
            o.ProviderPhone ,
            o.ProviderFax ,
            o.EmployeeYN
    FROM    fact.OECClaimLineDetail o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;


		  
GO
