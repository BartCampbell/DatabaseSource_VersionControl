SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	10/05/2016
---- Description:	Gets the latest HEDIS Network data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetHEDISNetwork '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetHEDISNetwork]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            n.Network_BK AS CentauriNetworkID ,
            n.ClientNetworkID ,
		  s.Name AS ClientNetworkName
    FROM    dbo.H_Network n 
            INNER JOIN dbo.L_ProviderNetwork l ON l.H_Network_RK = n.H_Network_RK
		  INNER JOIN dbo.L_ProviderHEDIS p ON p.H_Provider_RK = l.H_Provider_RK
		  INNER JOIN dbo.S_Network s ON s.H_Network_RK = n.H_Network_RK
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;

GO
