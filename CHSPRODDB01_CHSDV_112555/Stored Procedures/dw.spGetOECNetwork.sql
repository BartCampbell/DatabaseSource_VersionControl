SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECNetwork]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Network_BK AS CentauriNetworkID ,
            h.ClientNetworkID ,
            s.Name AS ClientNetworkName
    FROM    dbo.H_Network h
            INNER JOIN dbo.S_Network s ON s.H_Network_RK = h.H_Network_RK
            INNER JOIN dbo.L_OECProviderNetwork l ON l.H_Network_RK = h.H_Network_RK
    WHERE   h.Network_BK IS NOT NULL
            AND s.LoadDate > @LastLoadTime;


GO
