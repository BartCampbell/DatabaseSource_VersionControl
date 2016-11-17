SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECProvider]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            s.NPI ,
            s.LastName ,
            s.FirstName
    FROM    dbo.H_Provider h
            INNER JOIN dbo.S_ProviderDemo s ON s.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.L_OECProviderLocation l ON l.H_Provider_RK = h.H_Provider_RK
    WHERE   h.Provider_BK IS NOT NULL
            AND s.LoadDate > @LastLoadTime;

GO
