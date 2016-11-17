SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECProviderClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientProviderID
    FROM    dbo.H_Provider h
            INNER JOIN dbo.L_OECProviderLocation lo ON lo.H_Provider_RK = h.H_Provider_RK
		  CROSS JOIN dbo.H_Client c 
    WHERE   lo.RecordEndDate IS NULL
            AND lo.LoadDate > @LastLoadTime;

GO
