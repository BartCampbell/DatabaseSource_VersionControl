SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- =============================================
-- Author:		Travis Parker
-- Create date:	08/19/2016
-- Description:	Loads all the Satellites from the OEC Enrollee Stratum staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OECStratum_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OECStratum_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            INSERT  INTO dbo.LS_MemberOECProjectStratum
                    ( LS_MemberOECProjectStratum_RK ,
                      L_MemberOECProject_RK ,
				  Issuer ,
                      Stratum ,
				  StratumDesc,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
                    )
                    SELECT DISTINCT
                            h.LS_MemberOECProjectStratum_RK ,
                            h.L_MemberOECProject_RK ,
					   h.Issuer ,
					   h.Stratum ,
					   h.Stratum_Description,
                            h.HashDiff ,
                            h.LoadDate ,
                            h.FileName
                    FROM    CHSStaging.oec.EnrolleeStratum_112548 h
                            LEFT JOIN dbo.LS_MemberOECProjectStratum s ON s.L_MemberOECProject_RK = h.L_MemberOECProject_RK
                                                                      AND s.RecordEndDate IS NULL
                                                                      AND s.HashDiff = h.HashDiff
                    WHERE   s.LS_MemberOECProjectStratum_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.LS_MemberOECProjectStratum
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.LS_MemberOECProjectStratum AS z
                                      WHERE     z.L_MemberOECProject_RK = a.L_MemberOECProject_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.LS_MemberOECProjectStratum a
            WHERE   a.RecordEndDate IS NULL;


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;





GO
