SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



---- =============================================
---- Author:		Travis Parker
---- Create date:	10/06/2016
---- Description:	Gets the latest HEDIS Provider data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetHEDISProvider '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetHEDISProviderClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            p.Provider_BK AS CentauriProviderID,
		  c.Client_BK AS CentauriClientID,
		  ISNULL(p.ClientProviderID,'') AS ClientProviderID
    FROM    dbo.H_Provider p 
            INNER JOIN dbo.L_ProviderHEDIS l ON l.H_Provider_RK = p.H_Provider_RK  
		  INNER JOIN dbo.S_ProviderDemo s ON s.H_Provider_RK = p.H_Provider_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;




GO
