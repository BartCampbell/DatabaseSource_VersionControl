SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	05/25/2016
-- Description:	Loads new members into the member reference table from the raps staging tables
-- Usage:			
--		  EXECUTE raps.prUpdateMemberReference
-- =============================================

CREATE PROCEDURE [raps].[prUpdateMemberReference]
@ClientID INT,
@FileName VARCHAR(100)
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW MEMBERS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    raps.RAPS_RESPONSE_CCC s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.HicNo = r.HICN
                                                          AND r.ClientID = @ClientID;

		   
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      HICN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  DISTINCT
					   @ClientID ,
                            NULL ,
                            s.HicNo ,
                            GETDATE() ,
                            @FileName
                    FROM    raps.RAPS_RESPONSE_CCC s
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HicNo = r.HICN
                                                              AND r.ClientID = @ClientID
                    WHERE   r.CentauriMemberID IS NULL;


            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    raps.RAPS_RESPONSE_CCC s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.HicNo = r.HICN
                                                          AND r.ClientID = @ClientID;


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
