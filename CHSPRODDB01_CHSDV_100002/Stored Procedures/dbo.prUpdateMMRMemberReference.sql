SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/28/2016
-- Description:	Loads new members into the member reference table from the MMR staging table
-- Usage:			
--		  EXECUTE dbo.prUpdateMMRMemberReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdateMMRMemberReference]
    @RecordSource VARCHAR(255),
    @ClientID INT
AS
    BEGIN

	   DECLARE @CurrentDate DATETIME = GETDATE()

        SET NOCOUNT ON;


        BEGIN TRY

            --LOAD NEW MEMBERS FROM MOR A STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      HICN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            @ClientID ,
                            s.HICN_Nbr ,
                            @CurrentDate ,
                            @RecordSource
                    FROM    CHSStaging.mmr.MMR_Stage s 
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HICN_Nbr = r.HICN
                                                                 AND @ClientID = r.ClientID
                    WHERE   r.CentauriMemberID IS NULL
                            AND ISNULL(s.HICN_Nbr, '') <> '';


		  --UPDATE STAGING REFERENCES
            UPDATE  s
            SET     CentauriMemberID = r.CentauriMemberID ,
                    H_Member_RK = r.MemberHashKey ,
                    ClientMemberID = r.ClientMemberID
            FROM    CHSStaging.mmr.MMR_Stage s 
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = s.HICN_Nbr
                                                       AND r.ClientID = @ClientID;

            --COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            --IF @@TRANCOUNT > 0
            --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;

GO
