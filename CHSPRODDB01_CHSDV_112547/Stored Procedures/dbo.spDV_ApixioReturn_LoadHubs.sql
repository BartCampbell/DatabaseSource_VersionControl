SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



---- =============================================
---- Author:		Travis Parker
---- Create date:	12/16/2016
---- Description:	Loads all the Hubs from the Apixio staging tables
---- Usage:			
----		  EXECUTE dbo.spDV_ApixioReturn_LoadHubs
---- =============================================

CREATE PROCEDURE [dbo].[spDV_ApixioReturn_LoadHubs]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            --LOAD Member HUB
            INSERT  INTO dbo.H_Member
                    ( H_Member_RK ,
                      Member_BK ,
				  ClientMemberID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_Member_RK ,
                            CentauriMemberID ,
					   MEMBER_ID ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   H_Member_RK IS NOT NULL
                            AND H_Member_RK NOT IN ( SELECT H_Member_RK
                                                     FROM   dbo.H_Member );--1
  

		  --LOAD Provider HUB
            INSERT  INTO dbo.H_Provider
                    ( H_Provider_RK ,
                      Provider_BK ,
                      ClientProviderID ,
                      RecordSource ,
                      LoadDate
                    )
                    SELECT  H_Provider_RK ,
                            CentauriProviderID ,
                            '' AS ClientProviderID ,
                            MIN(FileName) ,
                            GETDATE()
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   H_Provider_RK IS NOT NULL
                            AND H_Provider_RK NOT IN ( SELECT   H_Provider_RK
                                                       FROM     dbo.H_Provider )
                    GROUP BY H_Provider_RK ,
                            CentauriProviderID;--1


		  --LOAD Apixio Return HUB
            INSERT  INTO dbo.H_ApixioReturn
                    ( H_ApixioReturn_RK ,
                      ApixioReturn_BK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_ApixioReturn_RK ,
                            ApixioReturn_BK ,
                            GETDATE() ,
                            MIN(FileName)
                    FROM    CHSStaging.dbo.ApixioReturn
                    WHERE   H_ApixioReturn_RK IS NOT NULL
                            AND H_ApixioReturn_RK NOT IN ( SELECT   H_ApixioReturn_RK
                                                           FROM     dbo.H_ApixioReturn )
                    GROUP BY H_ApixioReturn_RK ,
                            ApixioReturn_BK;--1


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
