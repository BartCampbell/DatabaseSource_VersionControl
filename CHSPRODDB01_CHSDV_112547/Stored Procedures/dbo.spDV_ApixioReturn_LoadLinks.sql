SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	12/16/2016
-- Description:	Loads all the Links from the Apixio Return staging tables
-- Usage:			
--		  EXECUTE dbo.spDV_ApixioReturn_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[spDV_ApixioReturn_LoadLinks]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


		  --LOAD MemberApixioReturn Link
            INSERT  INTO dbo.L_MemberApixioReturn
                    ( L_MemberApixioReturn_RK ,
                      H_Member_RK ,
                      H_ApixioReturn_RK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  L_MemberApixioReturn_RK ,
                            H_Member_RK ,
                            H_ApixioReturn_RK ,
                            GETDATE() ,
                            MIN(FileName)
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   L_MemberApixioReturn_RK NOT IN ( SELECT L_MemberApixioReturn_RK
                                                             FROM   dbo.L_MemberApixioReturn )
                            AND L_MemberApixioReturn_RK IS NOT NULL
                    GROUP BY L_MemberApixioReturn_RK ,
                            H_Member_RK ,
                            H_ApixioReturn_RK; 
		  
		  --LOAD ProviderApixioReturn Link
            INSERT  INTO dbo.L_ProviderApixioReturn
                    ( L_ProviderApixioReturn_RK ,
                      H_Provider_RK ,
                      H_ApixioReturn_RK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  L_ProviderApixioReturn_RK ,
                            H_Provider_RK ,
                            H_ApixioReturn_RK ,
                            GETDATE() ,
                            MIN(FileName)
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   L_ProviderApixioReturn_RK NOT IN ( SELECT   L_ProviderApixioReturn_RK
                                                               FROM     dbo.L_ProviderApixioReturn )
                            AND L_ProviderApixioReturn_RK IS NOT NULL
                    GROUP BY L_ProviderApixioReturn_RK ,
                            H_Provider_RK ,
                            H_ApixioReturn_RK; 
		  
		  --LOAD SuspectApixioReturn Link
            INSERT  INTO dbo.L_SuspectApixioReturn
                    ( L_SuspectApixioReturn_RK ,
                      H_Suspect_RK ,
                      H_ApixioReturn_RK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            L_SuspectApixioReturn_RK ,
                            H_Suspect_RK ,
                            H_ApixioReturn_RK ,
                            GETDATE() ,
                            MIN(FileName)
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   L_SuspectApixioReturn_RK NOT IN ( SELECT    L_SuspectApixioReturn_RK
                                                              FROM      dbo.L_SuspectApixioReturn )
                            AND L_SuspectApixioReturn_RK IS NOT NULL
                    GROUP BY L_SuspectApixioReturn_RK ,
                            H_Suspect_RK ,
                            H_ApixioReturn_RK; 
				

        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
