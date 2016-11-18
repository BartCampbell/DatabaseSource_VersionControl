SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/28/2016
-- Description:	retrieves provider office data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECProviderOffice_112550 '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECProviderOffice_112550]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 


    SELECT DISTINCT
            pl.ProviderLocationID AS ProviderOffice_PK ,
		  pcl.ClientProviderID ,
            pl.Advance_Addr1 ,
            NULLIF(pl.Advance_Zip,'') Advance_Zip,
		  pl.Advance_Phone,
		  pl.Advance_Fax,
		  o.ProviderRelationsRep,
		  p.CentauriProviderID AS ProviderID
    FROM    fact.OEC o
		  INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
		  INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
		  INNER JOIN dim.ProviderClient pcl ON c.ClientID = pcl.ClientID AND pl.ProviderID = pcl.ProviderID
		  INNER JOIN dim.Provider p ON p.ProviderID = o.ProviderID
    WHERE   op.ProjectID = @ProjectID AND c.CentauriClientID = @CentauriClientID


		  
GO
