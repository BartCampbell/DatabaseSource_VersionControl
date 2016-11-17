SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









-- =============================================
-- Author:		Travis Parker
-- Create date:	09/13/2016
-- Description:	Loads all the Satellites from the OEC Enrollee DNC staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OECDNC_LoadSats
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OECDNC_LoadSats]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

            INSERT INTO dbo.S_OEC_DNC
                    ( S_OEC_DNC_RK ,
                      H_OEC_RK ,
                      Issuer ,
                      Claim_ID ,
                      HashDiff ,
                      RecordSource ,
                      LoadDate
                    )
                    SELECT DISTINCT
                            h.S_OEC_DNC_RK ,
                            h.H_OEC_RK ,
                            h.Issuer ,
                            h.Claim_ID ,
                            h.HashDiff ,
                            h.FileName ,
                            h.LoadDate
                    FROM    CHSStaging.oec.DoNotChase_112548 h
                            LEFT JOIN dbo.S_OEC_DNC s ON s.H_OEC_RK = h.H_OEC_RK
                                                                      AND s.RecordEndDate IS NULL
                                                                      AND s.HashDiff = h.HashDiff
                    WHERE   s.S_OEC_DNC_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_OEC_DNC
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                      FROM      dbo.S_OEC_DNC AS z
                                      WHERE     z.H_OEC_RK = a.H_OEC_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_OEC_DNC a
            WHERE   a.RecordEndDate IS NULL;


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;





GO
