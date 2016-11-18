SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	08/21/2016
-- Description:	merges the stage to fact for OEC ClaimLineDetail
-- Usage:			
--		  EXECUTE dbo.spOECMergeClaimLineDetail
-- =============================================
CREATE PROC [dbo].[spOECMergeClaimLineDetail]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.OECClaimLineDetail AS t
        USING
            ( SELECT    m.MemberID ,
                        op.OECProjectID ,
                        o.ChaseID ,
                        o.MemberID AS ClientMemberID ,
                        o.ClaimID ,
                        o.ServiceLine ,
                        o.RevenueCode ,
                        o.ServiceCode ,
                        o.ServiceModifierCode ,
                        o.BillTypeCode ,
                        o.FacilityTypeCode ,
                        o.ProviderNPI ,
                        o.ProviderLastName ,
                        o.ProviderFirstName ,
                        o.ProviderSpecialty ,
                        o.ProviderAddress ,
                        o.ProviderCity ,
                        o.ProviderState ,
                        o.ProviderZip ,
                        o.ProviderPhone ,
                        o.ProviderFax ,
                        o.EmployeeYN
              FROM      stage.OECClaimLineDetail o
                        INNER JOIN dim.OECProject op ON op.CentauriOECProjectID = o.CentauriProjectID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = o.CentauriMemberID
            ) AS s
        ON t.OECProjectID = s.OECProjectID
            AND t.MemberID = s.MemberID
            AND t.ChaseID = s.ChaseID
            AND t.ClaimID = s.ClaimID
            AND t.ServiceLine = s.ServiceLine
            AND t.ProviderAddress = s.ProviderAddress
            AND t.ProviderPhone = s.ProviderPhone
        WHEN MATCHED AND ( ISNULL(t.RevenueCode, '') <> ISNULL(s.RevenueCode, '')
					  OR ISNULL(t.ClientMemberID,'') <> ISNULL(s.ClientMemberID,'')
                           OR ISNULL(t.ServiceCode, '') <> ISNULL(s.ServiceCode, '')
                           OR ISNULL(t.ServiceModifierCode, '') <> ISNULL(s.ServiceModifierCode, '')
                           OR ISNULL(t.BillTypeCode, '') <> ISNULL(s.BillTypeCode, '')
                           OR ISNULL(t.FacilityTypeCode, '') <> ISNULL(s.FacilityTypeCode, '')
                           OR ISNULL(t.ProviderNPI, '') <> ISNULL(s.ProviderNPI, '')
                           OR ISNULL(t.ProviderLastName, '') <> ISNULL(s.ProviderLastName, '')
                           OR ISNULL(t.ProviderFirstName, '') <> ISNULL(s.ProviderFirstName, '')
                           OR ISNULL(t.ProviderSpecialty, '') <> ISNULL(s.ProviderSpecialty, '')
                           OR ISNULL(t.ProviderCity, '') <> ISNULL(s.ProviderCity, '')
                           OR ISNULL(t.ProviderState, '') <> ISNULL(s.ProviderState, '')
                           OR ISNULL(t.ProviderZip, '') <> ISNULL(s.ProviderZip, '')
                           OR ISNULL(t.ProviderFax, '') <> ISNULL(s.ProviderFax, '')
                           OR ISNULL(t.EmployeeYN, '') <> ISNULL(s.EmployeeYN, '')
                         ) THEN
            UPDATE SET
                    t.RevenueCode = s.RevenueCode ,
				t.ClientMemberID = s.ClientMemberID ,
                    t.ServiceCode = s.ServiceCode ,
                    t.ServiceModifierCode = s.ServiceModifierCode ,
                    t.BillTypeCode = s.BillTypeCode ,
                    t.FacilityTypeCode = s.FacilityTypeCode ,
                    t.ProviderNPI = s.ProviderNPI ,
                    t.ProviderLastName = s.ProviderLastName ,
                    t.ProviderFirstName = s.ProviderFirstName ,
                    t.ProviderSpecialty = s.ProviderSpecialty ,
                    t.ProviderCity = s.ProviderCity ,
                    t.ProviderState = s.ProviderState ,
                    t.ProviderZip = s.ProviderZip ,
                    t.ProviderFax = s.ProviderFax ,
                    t.EmployeeYN = s.EmployeeYN ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( MemberID ,
                     OECProjectID ,
                     ChaseID ,
                     ClientMemberID ,
                     ClaimID ,
                     ServiceLine ,
                     RevenueCode ,
                     ServiceCode ,
                     ServiceModifierCode ,
                     BillTypeCode ,
                     FacilityTypeCode ,
                     ProviderNPI ,
                     ProviderLastName ,
                     ProviderFirstName ,
                     ProviderSpecialty ,
                     ProviderAddress ,
                     ProviderCity ,
                     ProviderState ,
                     ProviderZip ,
                     ProviderPhone ,
                     ProviderFax ,
                     EmployeeYN ,
                     CreateDate ,
                     LastUpdate
                   )
            VALUES ( s.MemberID ,
                     s.OECProjectID ,
                     s.ChaseID ,
                     s.ClientMemberID ,
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
                     s.EmployeeYN ,
                     @CurrentDate ,
                     @CurrentDate
                   );

    END;     



GO
