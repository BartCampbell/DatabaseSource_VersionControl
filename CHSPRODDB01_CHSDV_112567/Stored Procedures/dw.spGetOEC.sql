SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOEC]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.OEC_BK ,
            s.ClaimID ,
            s.DiagnosisCode ,
            s.ICD_Indicator ,
            s.DOS_FromDate ,
            s.DOS_ToDate ,
		  s.ContractCode ,
		  c.Client_BK AS CentauriClientID ,
            m.Member_BK AS CentauriMemberID ,
            p.Provider_BK AS CentauriProviderID ,
		  n.Network_BK AS CentauriNetworkID,
		  v.Vendor_BK AS VendorID,
            sl.Address1 AS ProviderAddr1 ,
            sl.Address2 AS ProviderAddr2 ,
            sl.City AS ProviderCity ,
            sl.State AS ProviderState ,
            sl.Zip AS ProviderZip,
		  cps.Phone AS ProviderPhone,
		  cps.Fax AS ProviderFax,
		  sl2.Address1 AS VendorAddr1 ,
            sl2.Address2 AS VendorAddr2 ,
            sl2.City AS VendorCity ,
            sl2.State AS VendorState ,
            sl2.Zip AS VendorZip,
		  cvs.Phone AS VendorPhone,
		  cvs.Fax AS VendorFax,
		  hop.OECProject_BK AS CentauriOECProjectID,
		  s.MemberHICN,
		  s.ChaseID,
		  s.ChasePriority,
		  s.MedicalRecordID,
		  s.ProviderRelationsRep,
		  s.ProviderSpecialty
    FROM    dbo.H_OEC h
		  CROSS JOIN dbo.H_Client c
		  INNER JOIN dbo.L_OECProjectOEC lop ON lop.H_OEC_RK = h.H_OEC_RK
		  INNER JOIN dbo.H_OECProject hop ON hop.H_OECProject_RK = lop.H_OECProject_RK
            INNER JOIN dbo.S_OECDetail s ON s.H_OEC_RK = h.H_OEC_RK AND s.RecordEndDate IS NULL
            LEFT JOIN dbo.L_MemberOEC lm ON lm.H_OEC_RK = h.H_OEC_RK
            LEFT JOIN dbo.H_Member m ON m.H_Member_RK = lm.H_Member_RK
            LEFT JOIN dbo.L_OECProviderLocation lp ON lp.H_OEC_RK = h.H_OEC_RK
            LEFT JOIN dbo.H_Provider p ON p.H_Provider_RK = lp.H_Provider_RK
            LEFT JOIN dbo.S_Location sl ON sl.H_Location_RK = lp.H_Location_RK AND sl.RecordEndDate IS NULL
		  LEFT JOIN dbo.L_OECProviderNetwork ln ON h.H_OEC_RK = ln.H_OEC_RK
		  LEFT JOIN dbo.H_Network n ON ln.H_Network_RK = n.H_Network_RK 
		  LEFT JOIN dbo.L_OECVendorLocation lv ON lv.H_OEC_RK = h.H_OEC_RK
		  LEFT JOIN dbo.H_Vendor v ON lv.H_Vendor_RK = v.H_Vendor_RK
            LEFT JOIN dbo.S_Location sl2 ON sl2.H_Location_RK = lv.H_Location_RK AND sl2.RecordEndDate IS NULL
		  LEFT JOIN dbo.L_OECProviderContact lcp ON lcp.H_OEC_RK = h.H_OEC_RK
		  LEFT JOIN dbo.S_Contact cps ON lcp.H_Contact_RK = cps.H_Contact_RK AND cps.RecordEndDate IS NULL
		  LEFT JOIN dbo.L_OECProviderContact lcv ON lcv.H_OEC_RK = h.H_OEC_RK
		  LEFT JOIN dbo.S_Contact cvs ON lcv.H_Contact_RK = cvs.H_Contact_RK AND cvs.RecordEndDate IS NULL
    WHERE   s.LoadDate > @LastLoadTime;


GO
