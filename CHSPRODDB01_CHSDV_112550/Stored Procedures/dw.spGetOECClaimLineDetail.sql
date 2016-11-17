SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECClaimLineDetail]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            CONVERT(BIGINT,m.Member_BK) AS CentauriMemberID ,
		  CONVERT(INT,c.Client_BK) AS CentauriClientID,
		  CONVERT(INT,hop.OECProject_BK) AS CentauriProjectID,
            s.ChaseID ,
            s.MemberID ,
            s.ClaimID ,
            s.ServiceLine ,
            s.RevenueCode ,
            s.ServiceCode ,
            s.ServiceModifierCode ,
            s.BillTypeCode ,
            s.FacilityTypeCode ,
            s.ProviderNPI ,
            s.ProviderLastName ,
            s.ProviderFirstName ,
            s.ProviderSpecialty ,
            s.ProviderAddress ,
            s.ProviderCity ,
            s.ProviderState ,
            s.ProviderZip ,
            s.ProviderPhone ,
            s.ProviderFax ,
            s.EmployeeYN 
    FROM    dbo.H_OEC h 
		  INNER JOIN dbo.L_MemberOEC l ON l.H_OEC_RK = h.H_OEC_RK 
		  INNER JOIN dbo.H_Member m ON m.H_Member_RK = l.H_Member_RK
		  INNER JOIN dbo.S_OECClaimDetail s ON h.H_OEC_RK = s.H_OEC_RK
		  INNER JOIN dbo.L_OECProjectOEC lop ON lop.H_OEC_RK = h.H_OEC_RK
		  INNER JOIN dbo.H_OECProject hop ON hop.H_OECProject_RK = lop.H_OECProject_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;


GO
