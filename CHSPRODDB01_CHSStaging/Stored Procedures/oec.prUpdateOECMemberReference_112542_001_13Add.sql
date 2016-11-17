SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








-- =============================================
-- Author:		Travis Parker
-- Create date:	10/04/2016
--Update 10/19/2016 based on [oec].[prUpdateOECMemberReference_112542_001_20Add] PJ
-- Description:	Loads new members into the member reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.prUpdateOECMemberReference_112542_001_13Add
-- =============================================

CREATE PROCEDURE [oec].[prUpdateOECMemberReference_112542_001_13Add]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW MEMBERS FROM 187 STAGING
            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    oec.AdvanceOECRaw_112542_001_13Add s
                    INNER JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                          AND r.ClientID = s.ClientID;

--SELECT clientid, * FROM oec.AdvanceOECRaw_112542_001_13Add
		   
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
                    FROM    oec.AdvanceOECRaw_112542_001_13Add s
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.MemberID = r.ClientMemberID
                                                              AND r.ClientID = s.ClientID
                    WHERE   r.CentauriMemberID IS NULL;


            UPDATE  s
            SET     s.CentauriMemberID = r.CentauriMemberID,
				s.H_Member_RK = r.MemberHashKey
            FROM    oec.AdvanceOECRaw_112542_001_13Add s
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
