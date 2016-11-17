SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	05/19/2016
-- Description:	Loads all the Satellites from the 834 staging tables
-- Usage:			
--		  EXECUTE dbo.prDV_834_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[prDV_834_LoadSats]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY


             --Load MemberDemo Satelite
             INSERT INTO dbo.S_MemberDemo
                (
                  S_MemberDemo_RK,
                  LoadDate,
                  H_Member_RK,
                  FirstName,
                  LastName,
                  Gender,
                  DOB,
                  HashDiff,
                  RecordSource
                )
                    SELECT DISTINCT
                         i.S_MemberDemo_RK,
                         i.LoadDate,
                         i.H_Member_RK,
                         i.Member_FirstName_NM104,
                         i.Member_LastName_OrgName_NM103,
                         i.Member_Gender_DMG03,
                         i.Member_DOB_DMG02,
                         i.S_MemberDemo_HashDiff,
                         i.RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport AS i
                          LEFT JOIN dbo.S_MemberDemo AS s ON i.H_Member_RK = s.H_Member_RK
                                                             AND s.RecordEndDate IS NULL
                                                             AND i.S_MemberDemo_HashDiff = s.HashDiff
                    WHERE s.S_MemberDemo_RK IS NULL;

             --RECORD END DATE CLEANUP
             UPDATE dbo.S_MemberDemo
             SET
                 RecordEndDate =
             (
                 SELECT
                      DATEADD(ss, -1, MIN(z.LoadDate))
                 FROM  dbo.S_MemberDemo AS z
                 WHERE z.H_Member_RK = a.H_Member_RK
                       AND z.LoadDate > a.LoadDate
             )
             FROM dbo.S_MemberDemo a
             WHERE
                  a.RecordEndDate IS NULL;

		  
             --Load MemberHICN Satelite
             INSERT INTO dbo.S_MemberHICN
                (
                  S_MemberHICN_RK,
                  LoadDate,
                  H_Member_RK,
                  HICNumber,
			   HashDiff,
                  RecordSource
                )
                    SELECT DISTINCT
                         i.S_MemberHICN_RK,
                         i.LoadDate,
                         i.H_Member_RK,
                         i.MemberLevelDetail_RefID3_REF02,
					i.S_MemberHICN_HashDiff,
                         i.RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport AS i
                          LEFT JOIN dbo.S_MemberHICN AS s ON i.H_Member_RK = s.H_Member_RK
                                                             AND s.RecordEndDate IS NULL
                                                             AND i.S_MemberHICN_HashDiff = s.HashDiff
                    WHERE s.S_MemberHICN_RK IS NULL AND NULLIF(i.MemberLevelDetail_RefID3_REF02,'NULL') IS NOT NULL 


             --RECORD END DATE CLEANUP
             UPDATE dbo.S_MemberHICN
             SET
                 RecordEndDate =
             (
                 SELECT
                      DATEADD(ss, -1, MIN(z.LoadDate))
                 FROM  dbo.S_MemberHICN AS z
                 WHERE z.H_Member_RK = a.H_Member_RK
                       AND z.LoadDate > a.LoadDate
             )
             FROM dbo.S_MemberHICN a
             WHERE
                  a.RecordEndDate IS NULL;


		  --LOAD Member Eligibility Satelite
		  INSERT INTO dbo.S_MemberEligibility
			(
			  S_MemberElig_RK,
			  LoadDate,
			  H_Member_RK,
			  EffectiveStartDate,
			  EffectiveEndDate,
			  GroupEffectiveDate,
			  ProviderID,
			  NetworkID,
			  Payor,
			  HashDiff,
			  RecordSource
			)
			    SELECT DISTINCT
				    i.S_MemberElig_RK,
				    i.LoadDate,
				    i.H_Member_RK,
				    NULLIF(i.MemberLevelDetail_DateTimePeriod1_DTP03,'NULL'),
				    NULLIF(i.MemberLevelDetail_DateTimePeriod2_DTP03,'NULL'),
				    NULL,
				    i.ProviderID,
				    i.NetworkID,
				    i.PlanLevelDetail_Payer_N102,
				    i.S_MemberElig_HashDiff,
				    i.RecordSource
			    FROM  CHSStaging.dbo.X12_834_RawImport AS i
					LEFT JOIN dbo.S_MemberEligibility AS s ON i.H_Member_RK = s.H_Member_RK
													  AND s.RecordEndDate IS NULL
													  AND i.S_MemberElig_HashDiff = s.HashDiff
			    WHERE s.S_MemberElig_RK IS NULL 


		   --RECORD END DATE CLEANUP
             UPDATE dbo.S_MemberEligibility
             SET
                 RecordEndDate =
             (
                 SELECT
                      DATEADD(ss, -1, MIN(z.LoadDate))
                 FROM  dbo.S_MemberEligibility AS z
                 WHERE z.H_Member_RK = a.H_Member_RK
                       AND z.LoadDate > a.LoadDate
             )
             FROM dbo.S_MemberEligibility a
             WHERE
                  a.RecordEndDate IS NULL;


		   --LOAD ProviderDemo Satellite
		  INSERT INTO dbo.S_ProviderDemo
			(
			  S_ProviderDemo_RK,
			  LoadDate,
			  H_Provider_RK,
			  NPI,
			  LastName,
			  FirstName,
			  HashDiff,
			  RecordSource
			)
			    SELECT DISTINCT
				    i.S_ProviderDemo_RK,
				    i.LoadDate,
				    i.H_Provider_RK,
				    NULL,
				    i.ProviderInfo_LastName_OrgName_NM103,
				    i.ProviderInfo_FirstName_NM104,
				    i.S_ProviderDemo_HashDiff,
				    i.RecordSource
			    FROM  CHSStaging.dbo.X12_834_RawImport AS i
			    LEFT JOIN dbo.S_ProviderDemo h ON i.H_Provider_RK = h.H_Provider_RK AND h.RecordEndDate IS NULL AND i.S_ProviderDemo_HashDiff = h.HashDiff
			    WHERE h.S_ProviderDemo_RK IS NULL;

		  --RECORD END DATE CLEANUP
		  UPDATE dbo.S_ProviderDemo
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.S_ProviderDemo AS z
			 WHERE z.H_Provider_RK = a.H_Provider_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.S_ProviderDemo a
		  WHERE
				a.RecordEndDate IS NULL;

		  --Load Contact Satellite
		  INSERT INTO dbo.S_Contact_834
		          ( S_Contact_834_RK ,
		            H_Contact_RK ,
		            Contact1Type ,
		            Contact1 ,
		            Contact2Type ,
		            Contact2 ,
		            Contact3Type ,
		            Contact3 ,
		            HashDiff ,
		            RecordSource ,
		            LoadDate 
		          )
            SELECT DISTINCT
                    i.S_Contact_834_RK ,
                    i.H_Contact_RK ,
                    i.Member_CommunicationNumberQualifier_PER03 ,
                    i.Member_CommunicationNumber_PER04 ,
                    i.Member_CommunicationNumberQualifier_PER05 ,
                    i.Member_CommunicationNumber_PER06 ,
                    i.Member_CommunicationNumberQualifier_PER07 ,
                    i.Member_CommunicationNumber_PER08 ,
                    i.S_Contact_834_HashDiff ,
                    i.RecordSource ,
                    i.LoadDate
            FROM    CHSStaging.dbo.X12_834_RawImport i
                    LEFT JOIN dbo.S_Contact_834 s ON s.H_Contact_RK = i.H_Contact_RK
                                                     AND s.RecordEndDate IS NULL
                                                     AND s.HashDiff = i.S_Contact_834_HashDiff
            WHERE   s.S_Contact_834_RK IS NULL; 
		  
		  --RECORD END DATE CLEANUP
		  UPDATE dbo.S_Contact_834
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.S_Contact_834 AS z
			 WHERE z.H_Contact_RK = a.H_Contact_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.S_Contact_834 a
		  WHERE
				a.RecordEndDate IS NULL;


		  --LOAD Location Detail
		  INSERT INTO dbo.S_Location
		          ( S_Location_RK ,
		            LoadDate ,
		            H_Location_RK ,
		            Address1 ,
		            City ,
		            State ,
		            Zip ,
		            HashDiff ,
		            RecordSource
		          )
            SELECT DISTINCT
                    i.S_Location_RK ,
                    i.LoadDate ,
                    i.H_Location_RK ,
                    i.Member_Address_N301 ,
                    i.Member_CityName_N401 ,
                    i.Member_StateProvinceCode_N402 ,
                    i.Member_PostalCode_N403 ,
                    i.S_Location_HashDiff ,
                    i.RecordSource
            FROM    CHSStaging.dbo.X12_834_RawImport i
                    LEFT JOIN dbo.S_Location s ON s.H_Location_RK = i.H_Location_RK
                                                  AND s.RecordEndDate IS NULL
                                                  AND i.S_Location_HashDiff = s.HashDiff
            WHERE   s.S_Location_RK IS NULL; 


		  --LOAD PCP Effective Date
            INSERT  INTO dbo.LS_MemberProvider
                    ( LS_MemberProvider_RK ,
                      L_MemberProvider_RK ,
                      PCPEffectiveDate ,
                      HashDiff ,
                      RecordSource ,
                      LoadDate
		          )
                    SELECT DISTINCT
                            i.LS_MemberProvider_RK ,
                            i.L_MemberProvider_RK ,
                            NULLIF(i.HealthCoverage_DateTimePeriod1_DTP03,'NULL') ,
                            i.LS_MemberProvider_HashDiff ,
                            i.RecordSource ,
                            i.LoadDate
                    FROM    CHSStaging.dbo.X12_834_RawImport i
                            LEFT JOIN dbo.LS_MemberProvider s ON s.L_MemberProvider_RK = i.L_MemberProvider_RK
                                                                 AND s.RecordEndDate IS NULL
                                                                 AND i.LS_MemberProvider_HashDiff = s.HashDiff
                    WHERE   s.LS_MemberProvider_RK IS NULL AND NULLIF(i.HealthCoverage_DateTimePeriod1_DTP03,'NULL') IS NOT NULL; 

		  --RECORD END DATE CLEANUP
		  UPDATE dbo.LS_MemberProvider
		  SET
			 RecordEndDate =
		  (
			 SELECT
				    DATEADD(ss, -1, MIN(z.LoadDate))
			 FROM  dbo.LS_MemberProvider AS z
			 WHERE z.L_MemberProvider_RK = a.L_MemberProvider_RK
				    AND z.LoadDate > a.LoadDate
		  )
		  FROM dbo.LS_MemberProvider a
		  WHERE
				a.RecordEndDate IS NULL;


         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;


GO
