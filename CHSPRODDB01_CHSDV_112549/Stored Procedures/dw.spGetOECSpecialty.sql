SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECSpecialty]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            s.Specialty
    FROM    dbo.L_OECProviderLocation l
            INNER JOIN dbo.L_ProviderSpecialty lp ON lp.H_Provider_RK = l.H_Provider_RK
            INNER JOIN dbo.H_Specialty s ON s.H_Specialty_RK = lp.H_Specialty_RK
    WHERE   s.Specialty IS NOT NULL
            AND s.LoadDate > @LastLoadTime;

GO
