SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves provider data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECProviderMaster '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECProviderMaster]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
		  p.NPI AS Provider_ID ,
		  pc.ClientProviderID AS PIN ,
            p.NPI ,
            RTRIM(LTRIM(p.LastName)) LastName ,
            RTRIM(LTRIM(p.FirstName)) FirstName
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.Provider p ON p.ProviderID = o.ProviderID
		  INNER JOIN dim.ProviderClient pc ON pc.ClientID = c.ClientID AND pc.ProviderID = p.ProviderID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;



GO
