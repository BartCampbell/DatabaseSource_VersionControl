SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/25/2016
-- Description:	Loads new members into the member reference table from the MOR staging table
-- Usage:			
--		  EXECUTE dbo.prUpdateMORMemberReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdateMORMemberReference]
    @RecordSource VARCHAR(255),
    @ClientID INT
AS
    BEGIN

	   DECLARE @CurrentDate DATETIME = GETDATE()

        SET NOCOUNT ON;


        BEGIN TRY

            --BEGIN TRANSACTION;

            --LOAD NEW MEMBERS FROM MOR A STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      HICN ,
				  SSN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            @ClientID ,
                            s.HICN ,
					   s.SSN ,
                            @CurrentDate ,
                            @RecordSource
                    FROM    CHSStaging.mor.MOR_ARecord_Stage s 
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HICN = r.HICN
                                                                 AND @ClientID = r.ClientID
                    WHERE   r.CentauriMemberID IS NULL
                            AND ISNULL(s.HICN, '') <> '';
		  
		  --LOAD NEW MEMBERS FROM MOR B STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      HICN ,
				  SSN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            @ClientID ,
                            s.HICN ,
					   s.SSN ,
                            @CurrentDate ,
                            @RecordSource
                    FROM    CHSStaging.mor.MOR_BRecord_Stage s 
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HICN = r.HICN
                                                                 AND @ClientID = r.ClientID
                    WHERE   r.CentauriMemberID IS NULL
                            AND ISNULL(s.HICN, '') <> '';
		  
		  --LOAD NEW MEMBERS FROM MOR C STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      HICN ,
				  SSN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            @ClientID ,
                            s.HICN ,
					   s.SSN ,
                            @CurrentDate ,
                            @RecordSource
                    FROM    CHSStaging.mor.MOR_CRecord_Stage s 
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HICN = r.HICN
                                                                 AND @ClientID = r.ClientID
                    WHERE   r.CentauriMemberID IS NULL
                            AND ISNULL(s.HICN, '') <> '';

		  
		  --UPDATE REFERENCE SSN
            UPDATE  r
            SET     SSN = a.SSN
            FROM    CHSStaging.mor.MOR_ARecord_Stage a
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = a.HICN
                                                       AND r.ClientID = @ClientID
		  WHERE r.SSN IS NULL;
		  
            UPDATE  r
            SET     SSN = b.SSN
            FROM    CHSStaging.mor.MOR_BRecord_Stage b
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = b.HICN
                                                       AND r.ClientID = @ClientID
		  WHERE r.SSN IS NULL;
            
		  UPDATE  r
            SET     SSN = c.SSN
            FROM    CHSStaging.mor.MOR_CRecord_Stage c
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = c.HICN
                                                       AND r.ClientID = @ClientID
		  WHERE r.SSN IS NULL

		  
		  --UPDATE STAGING REFERENCES
            UPDATE  a
            SET     CentauriMemberID = r.CentauriMemberID ,
                    H_Member_RK = r.MemberHashKey ,
                    ClientMemberID = r.ClientMemberID
            FROM    CHSStaging.mor.MOR_ARecord_Stage a
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = a.HICN
                                                       AND r.ClientID = @ClientID;

            UPDATE  b
            SET     CentauriMemberID = r.CentauriMemberID ,
                    H_Member_RK = r.MemberHashKey ,
                    ClientMemberID = r.ClientMemberID
            FROM    CHSStaging.mor.MOR_BRecord_Stage b
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = b.HICN
                                                       AND r.ClientID = @ClientID;
		  
            UPDATE  c
            SET     CentauriMemberID = r.CentauriMemberID ,
                    H_Member_RK = r.MemberHashKey ,
                    ClientMemberID = r.ClientMemberID
            FROM    CHSStaging.mor.MOR_CRecord_Stage c
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = c.HICN
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
