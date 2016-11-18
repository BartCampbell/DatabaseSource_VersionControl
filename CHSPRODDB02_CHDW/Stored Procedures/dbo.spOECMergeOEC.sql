SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to fact for OEC
-- Usage:			
--		  EXECUTE dbo.spOECMergeOEC
-- =============================================
CREATE PROC [dbo].[spOECMergeOEC]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.OEC AS t
        USING
            ( SELECT    o.OEC_BK ,
                        o.ClaimID ,
                        o.DiagnosisCode ,
                        o.ICD_Indicator ,
                        o.DOS_FromDate ,
                        o.DOS_ToDate ,
				    o.Eff_Date ,
				    o.Exp_Date ,
				    o.ContractCode ,
                        m.MemberID ,
                        p.ProviderID ,
                        pl.ProviderLocationID ,
                        op.OECProjectID ,
				    mh.MemberHICNID ,
				    vl.VendorLocationID,
				    pc.ProviderContactID,
				    vc.VendorContactID ,
				    n.NetworkID,
				    o.ChaseID,
				    o.ChasePriority,
				    o.MedicalRecordID,
				    o.ProviderRelationsRep,
				    o.ProviderSpecialty,
				    o.DNC
              FROM      stage.OEC o
                        INNER JOIN dim.OECProject op ON op.CentauriOECProjectID = o.CentauriOECProjectID
                        INNER JOIN dim.Provider p ON p.CentauriProviderID = o.CentauriProviderID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = o.CentauriMemberID
                        INNER JOIN dim.ProviderLocation pl ON pl.ProviderID = p.ProviderID
                                                              AND pl.Addr1 = o.ProviderAddr1
                                                              AND pl.City = o.ProviderCity
                                                              AND pl.State = o.ProviderState
                                                              AND pl.Zip = o.ProviderZip
				    LEFT JOIN dim.MemberHICN mh ON mh.HICN = o.MemberHICN AND mh.MemberID = m.MemberID
				    LEFT JOIN dim.Vendor v ON v.ClientID = op.ClientID AND v.ClientVendorID = o.VendorID
				    LEFT JOIN dim.VendorLocation vl ON vl.VendorID = v.VendorID
                                                              AND vl.Addr1 = o.ProviderAddr1
                                                              AND vl.City = o.ProviderCity
                                                              AND vl.State = o.ProviderState
                                                              AND vl.Zip = o.ProviderZip
				    LEFT JOIN dim.ProviderContact pc ON pc.Phone = o.ProviderPhone AND pc.Fax = o.ProviderFax AND pc.ProviderID = p.ProviderID 
				    LEFT JOIN dim.VendorContact vc ON vc.Phone = o.VendorPhone AND vc.Fax = o.VendorFax AND vc.VendorID = v.VendorID
				    LEFT JOIN dim.Network n ON o.CentauriNetworkID = n.CentauriNetworkID
            ) AS s
        ON t.OECProjectID = s.OECProjectID
            AND t.ProviderID = s.ProviderID
            AND t.MemberID = s.MemberID
            AND t.DOS_FromDate = s.DOS_FromDate
            AND t.DOS_ToDate = s.DOS_ToDate
        WHEN MATCHED AND ( ISNULL(t.ClaimID,'') <> ISNULL(s.ClaimID,'')
                           OR ISNULL(t.DiagnosisCode,'') <> ISNULL(s.DiagnosisCode,'')
                           OR ISNULL(t.ICD_Indicator,'') <> ISNULL(s.ICD_Indicator,'')
                           OR t.DOS_FromDate <> s.DOS_FromDate
                           OR t.DOS_ToDate <> s.DOS_ToDate
					  OR ISNULL(t.Eff_Date,'') <> ISNULL(s.Eff_Date,'')
					  OR ISNULL(t.Exp_Date,'') <> ISNULL(s.Exp_Date,'')
					  OR ISNULL(t.ContractCode,'') <> ISNULL(s.ContractCode,'')
                           OR t.ProviderLocationID <> s.ProviderLocationID
					  OR t.MemberHICNID <> s.MemberHICNID
                           OR ISNULL(t.ProviderContactID,-1) <> ISNULL(s.ProviderContactID,-1)
                           OR ISNULL(t.VendorLocationID,-1) <> ISNULL(s.VendorLocationID,-1)
                           OR ISNULL(t.VendorContactID,-1) <> ISNULL(s.VendorContactID,-1)
                           OR ISNULL(t.NetworkID,-1) <> ISNULL(s.NetworkID,-1)
					  OR ISNULL(t.ChaseID,'') <> ISNULL(s.ChaseID,'')
					  OR ISNULL(t.ChasePriority,'') <> ISNULL(s.ChasePriority,'')
					  OR ISNULL(t.MedicalRecordID,'') <> ISNULL(s.MedicalRecordID,'')
					  OR ISNULL(t.ProviderRelationsRep,'') <> ISNULL(s.ProviderRelationsRep,'')
					  OR ISNULL(t.ProviderSpecialty,'') <> ISNULL(s.ProviderSpecialty,'')
					  OR ISNULL(t.DNC,'') <> ISNULL(s.DNC,'')
                         ) THEN
            UPDATE SET
                    t.ClaimID = s.ClaimID ,
                    t.DiagnosisCode = s.DiagnosisCode ,
                    t.ICD_Indicator = s.ICD_Indicator ,
                    t.DOS_FromDate = s.DOS_FromDate ,
                    t.DOS_ToDate = s.DOS_ToDate ,
				t.Eff_Date = s.Eff_Date ,
				t.Exp_Date = s.Exp_Date ,
				t.ContractCode = s.ContractCode ,
                    t.ProviderLocationID = s.ProviderLocationID ,
				t.MemberHICNID = s.MemberHICNID ,
				t.ProviderContactID = s.ProviderContactID,
				t.VendorLocationID = s.VendorLocationID,
				t.VendorContactID = s.VendorContactID,
				t.NetworkID = s.NetworkID,
				t.ChaseID = s.ChaseID,
				t.ChasePriority = s.ChasePriority,
				t.MedicalRecordID = s.MedicalRecordID,
				t.ProviderRelationsRep = s.ProviderRelationsRep,
				t.ProviderSpecialty = s.ProviderSpecialty,
				t.DNC = s.DNC,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( OECProjectID ,
                     ProviderID ,
                     MemberID ,
                     ProviderLocationID ,
				 MemberHICNID ,
                     ClaimID ,
                     DiagnosisCode ,
                     ICD_Indicator ,
                     DOS_FromDate ,
                     DOS_ToDate,
				 Eff_Date,
				 Exp_Date,
				 ContractCode,
				 ProviderContactID,
				 VendorLocationID,
				 VendorContactID,
				 NetworkID,
				 ChaseID,
				 ChasePriority,
				 MedicalRecordID,
				 ProviderRelationsRep,
				 ProviderSpecialty,
				 DNC
                   )
            VALUES ( OECProjectID ,
                     ProviderID ,
                     MemberID ,
                     ProviderLocationID ,
				 MemberHICNID ,
                     ClaimID ,
                     DiagnosisCode ,
                     ICD_Indicator ,
                     DOS_FromDate ,
                     DOS_ToDate,
				 Eff_Date,
				 Exp_Date,
				 ContractCode,
				 ProviderContactID,
				 VendorLocationID,
				 VendorContactID,
				 NetworkID,
				 ChaseID,
				 ChasePriority,
				 MedicalRecordID,
				 ProviderRelationsRep,
				 ProviderSpecialty,
				 DNC
                   );

    END;     


GO
