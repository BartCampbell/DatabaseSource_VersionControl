SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves suspect data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECSuspect '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECSuspect]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            op.ProjectName,
		  pc.ClientProviderID,
		  mc.ClientMemberID,
		  ISNULL(NULLIF(o.ChaseID,''),o.OECID) AS ChaseID,
		  o.ProviderSpecialty,
		  o.ContractCode,
		  o.ChasePriority,
		  o.MedicalRecordID,
		  o.DNC
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.Member m ON o.MemberID = m.MemberID
		  INNER JOIN dim.MemberClient mc ON c.ClientID = mc.ClientID AND m.MemberID = mc.MemberID
		  INNER JOIN dim.Provider p ON o.ProviderID = p.ProviderID
		  INNER JOIN dim.ProviderClient pc ON c.ClientID = pc.ClientID AND p.ProviderID = pc.ProviderID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;


		  
GO
