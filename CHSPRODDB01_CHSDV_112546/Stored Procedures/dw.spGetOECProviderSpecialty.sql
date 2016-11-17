SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECProviderSpecialty]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            s.Specialty
    FROM    dbo.H_Provider h
            INNER JOIN dbo.L_OECProviderLocation l ON l.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.L_ProviderSpecialty lp ON lp.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.H_Specialty s ON s.H_Specialty_RK = lp.H_Specialty_RK
    WHERE   lp.RecordEndDate IS NULL
            AND lp.LoadDate > @LastLoadTime;

GO
