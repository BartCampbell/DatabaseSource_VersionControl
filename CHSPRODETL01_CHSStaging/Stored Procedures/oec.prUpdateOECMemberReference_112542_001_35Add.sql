SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:		Travis Parker
-- Create date:	10/04/2016
-- Description:	Loads new members into the member reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.prUpdateOECMemberReference_112542_001_35Add
-- =============================================

CREATE PROCEDURE [oec].[prUpdateOECMemberReference_112542_001_35Add]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW MEMBERS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    oec.AdvanceOECRaw_112542_001_35Add s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                          AND r.ClientID = s.ClientID;

--SELECT * FROM oec.AdvanceOECRaw_112542_001_35Add
		   
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
                            s.FileName
                    FROM    oec.AdvanceOECRaw_112542_001_35Add s
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                              AND r.ClientID = s.ClientID
                    WHERE   r.CentauriMemberID IS NULL;


            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    oec.AdvanceOECRaw_112542_001_35Add s
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
