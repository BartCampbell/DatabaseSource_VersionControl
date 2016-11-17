SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:		Travis Parker
-- Create date:	08/19/2016
-- Description:	Loads all the Satellites from the OEC Enrollee HCC staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OECHCC_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OECHCC_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            INSERT  INTO dbo.LS_MemberOECProjectHCC
                    ( LS_MemberOECProjectHCC_RK ,
                      L_MemberOECProject_RK ,
                      HCC ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
                    )
                    SELECT DISTINCT
                            h.LS_MemberOECProjectHCC_RK ,
                            h.L_MemberOECProject_RK ,
                            h.HCC ,
                            h.HashDiff ,
                            h.LoadDate ,
                            h.FileName
                    FROM    CHSStaging.oec.EnrolleeHCC_112549 h
                            LEFT JOIN dbo.LS_MemberOECProjectHCC s ON s.L_MemberOECProject_RK = h.L_MemberOECProject_RK
                                                                      AND s.RecordEndDate IS NULL
                                                                      AND s.HashDiff = h.HashDiff
                    WHERE   s.LS_MemberOECProjectHCC_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.LS_MemberOECProjectHCC
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.LS_MemberOECProjectHCC AS z
                                      WHERE     z.L_MemberOECProject_RK = a.L_MemberOECProject_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.LS_MemberOECProjectHCC a
            WHERE   a.RecordEndDate IS NULL;


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
