SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
 
-- ============================================= 
-- Author:		Travis Parker 
-- Create date:	02/10/2017 
-- Description:	Loads new members into the member reference table from the TRR staging table 
-- Usage:			 
--		  EXECUTE dbo.spTRRUpdateMemberReference 
-- ============================================= 
 
CREATE PROCEDURE [dbo].[spTRRUpdateMemberReference] 
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
                            s.ClientID , 
                            s.HICN , 
                            @CurrentDate , 
                            s.FileName 
                    FROM    CHSStaging.dbo.TRRStaging s  
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON s.HICN = r.HICN 
                                                                 AND s.ClientID = r.ClientID 
                    WHERE   r.CentauriMemberID IS NULL 
                            AND ISNULL(s.HICN, '') <> ''; 
 
 
		  --UPDATE STAGING REFERENCES 
            UPDATE  s 
            SET     CentauriMemberID = r.CentauriMemberID , 
                    H_Member_RK = r.MemberHashKey , 
				ClientMemberID = ISNULL(r.ClientMemberID,'') 
            FROM    CHSStaging.dbo.TRRStaging s  
                    INNER JOIN CHSDV.dbo.R_Member r ON r.HICN = s.HICN 
                                                       AND r.ClientID = s.ClientID; 
 
            --COMMIT TRANSACTION; 
        END TRY 
        BEGIN CATCH 
            --IF @@TRANCOUNT > 0 
            --    ROLLBACK TRANSACTION; 
            THROW; 
        END CATCH; 
    END; 
 
 
GO
