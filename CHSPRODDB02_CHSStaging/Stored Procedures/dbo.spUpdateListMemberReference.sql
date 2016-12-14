SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Paul Johnson
-- Create date:	11/30/2016
-- Description:	Loads new members into the member reference table from a chase list in staging tables
-- Usage:			
--		  based on  oec.prUpdateOECMemberReference_112547
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateListMemberReference]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW MEMBERS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
			     FROM     [CHSStaging].[dbo].[ChaseListDVStage]  s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                          AND r.ClientID = s.ClientID;

			
		   

            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      HICN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  DISTINCT
					   s.ClientID ,
                            s.MemberID ,
                            s.MemberHICN ,
                            s.LoadDate ,
                            'WellCareChaseList3'
                    FROM      [CHSStaging].[dbo].[ChaseListDVStage]  s
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                              AND r.ClientID = s.ClientID
                    WHERE   r.CentauriMemberID IS NULL AND  s.CentauriMemberID IS NULL;


            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM   [CHSStaging].[dbo].[ChaseListDVStage]  s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                          AND r.ClientID = s.ClientID;


			











            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
