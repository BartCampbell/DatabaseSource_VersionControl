SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	06/10/2016
---- Description:	Loads all the Hubs from the RAPS staging tables
---- Usage:			
----		  EXECUTE dbo.prDV_RAPS_LoadHubs
---- =============================================

CREATE PROCEDURE [dbo].[prDV_RAPS_LoadHubs]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


             --LOAD Member HUB
            INSERT  INTO dbo.H_Member
                    ( H_Member_RK ,
                      Member_BK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_Member_RK ,
                            CentauriMemberID ,
                            LoadDate ,
                            RecordSource
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC
                    WHERE   H_Member_RK IS NOT NULL
                            AND H_Member_RK NOT IN ( SELECT H_Member_RK
                                                     FROM   dbo.H_Member );

		  --LOAD Client HUB
            INSERT  INTO dbo.H_Client
                    ( H_Client_RK ,
                      Client_BK ,
                      ClientName ,
                      RecordSource ,
                      LoadDate
		          )
                    SELECT DISTINCT
                            H_Client_RK ,
                            ClientID ,
                            ClientName ,
                            RecordSource ,
                            LoadDate
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC
                    WHERE   H_Client_RK NOT IN ( SELECT H_Client_RK
                                                 FROM   dbo.H_Client );		  


		  --LOAD RAPS HUB
            INSERT  INTO dbo.H_RAPS_Response
                    ( H_RAPS_Response_RK ,
                      RAPS_Response_BK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_RAPS_Response_RK ,
					   RAPS_Response_BK ,
                            LoadDate ,
                            RecordSource
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC
                    WHERE   H_RAPS_Response_RK NOT IN ( SELECT    H_RAPS_Response_RK
                                              FROM      dbo.H_RAPS_Response );





        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
