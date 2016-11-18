SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/28/2016
-- Description:	retrieves provider office data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECProviderOffice_112547 '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECProviderOffice_112547]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            pl.ProviderLocationID AS ProviderOffice_PK ,
		  pcl.ClientProviderID ,
            pl.Advance_Addr1 ,
            pl.Advance_Zip,
		  pl.Advance_Phone,
		  pl.Advance_Fax,
		  o.ProviderRelationsRep,
		  p.CentauriProviderID AS ProviderID
    FROM    fact.OEC o
            INNER JOIN dim.ProviderLocation pl ON pl.ProviderLocationID = o.ProviderLocationID
		  INNER JOIN dim.ProviderClient pcl ON 5 = pcl.ClientID AND pl.ProviderID = pcl.ProviderID
		  INNER JOIN dim.Provider p ON p.ProviderID = o.ProviderID
    WHERE   o.OECProjectID = 2


		  
GO
