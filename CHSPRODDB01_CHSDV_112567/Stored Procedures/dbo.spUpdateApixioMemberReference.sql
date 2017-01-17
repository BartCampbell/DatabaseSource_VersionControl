SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	12/14/2016
-- Description:	Loads new members into the member reference table from the apixio return staging table
-- Usage:			
--		  EXECUTE dbo.spUpdateApixioMemberReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateApixioMemberReference]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            --BEGIN TRANSACTION;

		  --update the matches to current suspect members
            UPDATE  a
            SET     a.CentauriMemberID = s.CentauriMemberID
            FROM    CHSStaging.dbo.ApixioReturn AS a
                    INNER JOIN dbo.vwSuspectMember s ON a.Suspect_PK = s.Suspect_PK
                                                        AND LEFT(s.FirstName, 5) = LEFT(a.MEMBER_FIRST, 5)
                                                        AND LEFT(s.LastName, 5) = LEFT(a.MEMBER_LAST, 5)
            WHERE   a.CentauriMemberID IS NULL; 


		  --update the matches to current providers on NPI and Name
            UPDATE  a
            SET     a.CentauriMemberID = s.CentauriMemberID
            FROM    CHSStaging.dbo.ApixioReturn AS a
                    INNER JOIN dbo.vwSuspectMember s ON a.MEMBER_HICN = s.HICN
                                                        AND LEFT(a.MEMBER_FIRST, 5) = LEFT(s.FirstName, 5)
                                                        AND LEFT(a.MEMBER_LAST, 5) = LEFT(s.LastName, 5)
            WHERE   a.CentauriMemberID IS NULL; 

		  
             --LOAD NEW PROVIDERS FROM HEDIS STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      HICN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            c.Client_BK ,
                            i.MEMBER_ID ,
                            i.MEMBER_HICN ,
                            GETDATE() ,
                            i.FileName
                    FROM    CHSStaging.dbo.ApixioReturn AS i
                            CROSS JOIN dbo.H_Client c
                            LEFT JOIN CHSDV.dbo.R_Member r ON i.MEMBER_ID = r.ClientMemberID
                                                              AND c.Client_BK = r.ClientID
                    WHERE   ISNULL(i.MEMBER_ID, '') <> ''
                            AND r.CentauriMemberID IS NULL
                            AND i.CentauriMemberID IS NULL; 

            UPDATE  i
            SET     i.CentauriMemberID = r.CentauriMemberID
            FROM    CHSStaging.dbo.ApixioReturn AS i
                    CROSS JOIN dbo.H_Client c
                    INNER JOIN CHSDV.dbo.R_Member r ON i.MEMBER_ID = r.ClientMemberID
                                                       AND c.Client_BK = r.ClientID
            WHERE   ISNULL(i.MEMBER_ID, '') <> ''
                    AND i.CentauriMemberID IS NULL; 

            --COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            --IF @@TRANCOUNT > 0
            --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
