SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	12/16/2016
-- Description:	Loads all the Satellites from the Apixio Response staging tables
-- Usage:			
--		  EXECUTE dbo.spDV_ApixioReturn_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[spDV_ApixioReturn_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

		  --LOAD RAPS AAA
            INSERT INTO dbo.S_ApixioReturn
                    ( S_ApixioReturn_RK ,
                      H_ApixioReturn_RK ,
                      ReferenceNbr ,
                      ProviderNPI ,
                      ProviderLast ,
                      ProviderFirst ,
                      DateOfService ,
                      ProviderType ,
                      MemberID ,
                      MemberHICN ,
                      MemberLast ,
                      MemberFirst ,
                      MemberDOB ,
                      MemberGender ,
                      HCC ,
                      ICD9 ,
                      ICD10 ,
                      Comments ,
                      PatientUUID ,
                      DocumentUUID ,
                      ChartID ,
                      Page ,
                      CoderHistory ,
                      CoderAnnotationHistory ,
                      CodingDate ,
                      Delivered ,
                      PhaseComplete ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
                    )            
                    SELECT  a.S_ApixioReturn_RK, 
					   a.H_ApixioReturn_RK,
					   a.REFERENCE_NBR ,
                            a.PROVIDER_NPI ,
                            a.PROVIDER_LAST ,
                            a.PROVIDER_FIRST ,
                            a.DATE_OF_SERVICE ,
                            a.PROVIDER_TYPE ,
                            a.MEMBER_ID ,
                            a.MEMBER_HICN ,
                            a.MEMBER_LAST ,
                            a.MEMBER_FIRST ,
                            a.MEMBER_DOB ,
                            a.MEMBER_GENDER ,
                            a.HCC ,
                            a.ICD9 ,
                            a.ICD10 ,
                            a.COMMENTS ,
                            a.PATIENT_UUID ,
                            a.DOCUMENT_UUID ,
                            a.CHART_ID ,
                            a.PAGE ,
                            a.CODER_HISTORY ,
                            a.CODER_ANNOTATION_HISTORY ,
                            a.CODING_DATE ,
                            a.DELIVERED ,
                            a.PHASECOMPLETE ,
					   a.S_ApixioReturn_HashDiff ,
					   a.LoadDate ,
					   a.FileName                            
                    FROM    CHSStaging.dbo.ApixioReturn a 
                            LEFT JOIN dbo.S_ApixioReturn s ON s.H_ApixioReturn_RK = a.H_ApixioReturn_RK AND a.S_ApixioReturn_HashDiff = s.HashDiff AND s.RecordEndDate IS NULL 
                    WHERE   s.S_ApixioReturn_RK IS NULL AND a.S_ApixioReturn_RK IS NOT NULL ; 

				SELECT max(LEN(MEMBER_HICN)) FROM CHSStaging.dbo.ApixioReturn

				SELECT * 
				FROM CHSStaging.dbo.ApixioReturn 
				WHERE LEN(MEMBER_HICN) > 20
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_ApixioReturn
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_ApixioReturn AS z
                                      WHERE     z.H_ApixioReturn_RK = a.H_ApixioReturn_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_ApixioReturn a
            WHERE   a.RecordEndDate IS NULL;

		  
		  --INSERT NEW Providers ONLY (don't want to overwrite demo info with apixio data)
            INSERT  INTO dbo.S_ProviderMasterDemo
                    ( S_ProviderMasterDemo_RK ,
                      LoadDate ,
                      H_Provider_RK ,
                      ProviderMaster_PK ,
                      Provider_ID ,
                      NPI ,
                      TIN ,
                      PIN ,
                      LastName ,
                      FirstName ,
                      LastUpdated ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT a.S_ProviderMasterDemo_RK ,
                            GETDATE() ,
                            a.H_Provider_RK ,
                            '' ,
                            a.CentauriProviderID ,
                            a.PROVIDER_NPI ,
                            '' ,
                            '' ,
                            a.PROVIDER_LAST ,
                            a.PROVIDER_FIRST ,
                            '' ,
                            a.S_ProviderMasterDemo_HashDiff ,
                            a.FileName
                    FROM    CHSStaging.dbo.ApixioReturn a
                            LEFT JOIN dbo.S_ProviderMasterDemo s ON s.H_Provider_RK = a.H_Provider_RK
                    WHERE   s.S_ProviderMasterDemo_RK IS NULL AND a.S_ProviderMasterDemo_RK IS NOT NULL; 

		  
		  --LOAD MemberDemo satellite ONLY (don't want to overwrite demo info with apixio data)
            INSERT INTO dbo.S_MemberDemo
                    ( S_MemberDemo_RK ,
                      LoadDate ,
                      H_Member_RK ,
                      FirstName ,
                      LastName ,
                      Gender ,
                      DOB ,
                      HashDiff ,
                      RecordSource 
                    )
				SELECT  a.S_MemberDemo_RK ,
                            GETDATE() ,
                            a.H_Member_RK ,
                            a.MEMBER_FIRST ,
                            a.MEMBER_LAST ,
                            a.MEMBER_GENDER ,
                            a.MEMBER_DOB ,
                            a.S_MemberDemo_HashDiff ,
                            a.FileName 
                    FROM    CHSStaging.dbo.ApixioReturn a
                            LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = a.H_Member_RK
                    WHERE   s.S_MemberDemo_RK IS NULL AND a.S_MemberDemo_RK IS NOT NULL; 
				

		  ----LOAD MemberHICN satellite ONLY (don't want to overwrite HICN info with apixio data)
    --        INSERT INTO dbo.S_MemberHICN
    --                ( S_MemberHICN_RK ,
    --                  LoadDate ,
    --                  H_Member_RK ,
    --                  HICNumber ,
    --                  HashDiff ,
    --                  RecordSource 
    --                )
				--SELECT  a.S_MemberHICN_RK ,
    --                        GETDATE() ,
    --                        a.H_Member_RK ,
    --                        a.MEMBER_HICN ,
    --                        a.S_MemberHICN_HashDiff ,
    --                        a.FileName 
    --                FROM    CHSStaging.dbo.ApixioReturn a
    --                        LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = a.H_Member_RK
    --                WHERE   s.S_MemberHICN_RK IS NULL AND a.S_MemberHICN_RK IS NOT NULL ; 



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
