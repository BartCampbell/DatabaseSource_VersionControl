SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




---- =============================================
---- Author:		Travis Parker
---- Create date:	08/30/2016
---- Description:	Loads all the Hubs from the OEC staging table
---- Usage:			
----		  EXECUTE dbo.spDV_OECStratum_LoadHubs
---- =============================================

CREATE PROCEDURE [dbo].[spDV_OECStratum_LoadHubs]
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
                            Member_ID ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.EnrolleeStratum_112549
                    WHERE   H_Member_RK IS NOT NULL
                            AND H_Member_RK NOT IN ( SELECT H_Member_RK
                                                     FROM   dbo.H_Member );


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
