SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	08/15/2016
-- Description:	Loads all the Satellites from the OEC ClaimDetail staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OECClaimDetail_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OECClaimDetail_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            INSERT  INTO dbo.S_OECClaimDetail
                    ( S_OECClaimDetail_RK ,
                      H_OEC_RK ,
                      ChaseID ,
                      MemberID ,
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
                      HashDiff ,
                      RecordSource ,
                      LoadDate 
		          )
                    SELECT DISTINCT
                            s.S_OECClaimDetail_RK ,
                            s.H_OEC_RK ,
                            s.Chase_ID ,
                            s.Member_ID ,
                            s.Claim_ID ,
                            s.Service_Line ,
                            s.Revenue_Code ,
                            s.Service_Code ,
                            s.Service_Modifier_Code ,
                            s.Bill_Type_Code ,
                            s.Facility_Type_Code ,
                            s.Provider_NPI ,
                            s.Provider_Last_Name ,
                            s.Provider_First_Name ,
                            s.Provider_Specialty ,
                            s.Provider_Office_Address ,
                            s.Provider_Office_City ,
                            s.Provider_Office_State ,
                            s.Provider_Office_Zip ,
                            s.Provider_Office_Phone ,
                            s.Provider_Office_Fax ,
                            s.Employee_YN ,
                            s.HashDiff ,
                            s.FileName ,
                            s.LoadDate
                    FROM    CHSStaging.oec.ClaimLineDetail_112549 s
                            LEFT JOIN dbo.S_OECClaimDetail o ON o.H_OEC_RK = s.H_OEC_RK
                                                                AND o.RecordEndDate IS NULL
                                                                AND o.HashDiff = s.HashDiff
                    WHERE   o.S_OECClaimDetail_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_OECClaimDetail
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_OECClaimDetail AS z
                                      WHERE     z.H_OEC_RK = a.H_OEC_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_OECClaimDetail a
            WHERE   a.RecordEndDate IS NULL;


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
