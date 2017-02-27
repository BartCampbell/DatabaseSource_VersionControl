SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
 
---- ============================================= 
---- Author:		Travis Parker 
---- Create date:	07/06/2016 
---- Description:	Returns 1 or 0 as indicator if file has been processed 
---- Usage:			 
----		  EXECUTE dbo.prDV_RAPS_IsFileProcessed @IsFileProcessed  
---- ============================================= 
 
CREATE PROCEDURE [dbo].[prDV_RAPS_IsFileProcessed] 
    @IsFileProcessed INT OUTPUT 
AS 
    BEGIN 
 
        SET NOCOUNT ON; 
 
        BEGIN TRY 
 
 
            SELECT TOP 1 
                    @IsFileProcessed = t.FileProcessed 
            FROM    ( SELECT    1 AS FileProcessed 
                      FROM      CHSStaging.raps.RAPS_RESPONSE_AAA 
                      WHERE     RecordSource IN ( SELECT    RecordSource 
                                                  FROM      dbo.H_RAPS_Response ) 
                      UNION 
                      SELECT    0 AS FileProcessed 
                    ) t 
            ORDER BY t.FileProcessed DESC; 
 
        END TRY 
        BEGIN CATCH 
             --IF @@TRANCOUNT > 0 
             --    ROLLBACK TRANSACTION; 
            THROW; 
        END CATCH; 
    END; 
 
 
GO
