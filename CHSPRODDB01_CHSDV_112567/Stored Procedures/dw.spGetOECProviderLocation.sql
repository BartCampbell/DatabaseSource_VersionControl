SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECProviderLocation]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            sl.Address1 ,
            sl.Address2 ,
            sl.City ,
            sl.State ,
            sl.Zip ,
            sl.County
    FROM    dbo.H_Provider h
            INNER JOIN dbo.L_OECProviderLocation l ON l.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.H_Location hl ON hl.H_Location_RK = l.H_Location_RK
            INNER JOIN dbo.S_Location sl ON sl.H_Location_RK = hl.H_Location_RK
    WHERE   sl.RecordEndDate IS NULL
            AND sl.LoadDate > @LastLoadTime;


GO
