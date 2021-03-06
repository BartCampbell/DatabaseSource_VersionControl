SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- =============================================
-- Author:		Travis Parker
-- Create date:	08/30/2016
-- Description:	Loads new members into the member reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.spUpdateOECStratumMemberReference_112548
-- =============================================

CREATE PROCEDURE [oec].[spUpdateOECStratumMemberReference_112548]
    @FileName VARCHAR(255)
AS
    BEGIN

	   DECLARE @CurrentDate DATETIME = GETDATE();

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

		   
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT  DISTINCT
					   s.Client_ID ,
                            s.Member_ID ,
                            @CurrentDate ,
                            @FileName
                    FROM    oec.EnrolleeStratum_112548 s
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.Member_ID = r.ClientMemberID
                                                              AND r.ClientID = s.Client_ID
                    WHERE   r.CentauriMemberID IS NULL;



            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;







GO
