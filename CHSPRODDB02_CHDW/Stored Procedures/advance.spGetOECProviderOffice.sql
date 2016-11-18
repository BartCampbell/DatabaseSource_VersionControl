SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves provider office data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECProviderOffice '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECProviderOffice]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            pl.ProviderLocationID AS ProviderOffice_PK ,
		  pcl.ClientProviderID ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip,
		  pc.Phone,
		  pc.Fax,
		  o.ProviderRelationsRep
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
		  INNER JOIN dim.ProviderClient pcl ON c.ClientID = pcl.ClientID AND pl.ProviderID = pcl.ProviderID
		  INNER JOIN DIM.ProviderContact pc ON pc.ProviderContactID = o.ProviderContactID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;


		  
GO
