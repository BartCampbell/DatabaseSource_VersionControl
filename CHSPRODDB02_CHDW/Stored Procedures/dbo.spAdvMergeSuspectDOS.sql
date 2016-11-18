SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
--Update 9/20/2016 for WellCare PJ
-- Description:	merges the stage to dim for advance SuspectDOS 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeSuspectDOS
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeSuspectDOS]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.SuspectDOS AS t
        USING
            ( SELECT    sp.[SuspectID] ,
                        SuspectDOS_PK ,
                        DOS_From ,
                        DOS_To
              FROM      [stage].[SuspectDOS_ADV] ps
                        LEFT OUTER JOIN [fact].[Suspect] sp ON sp.CentauriSuspectID = ps.CentauriSuspectID
            ) AS s
        ON t.SuspectID = s.SuspectID
            AND ISNULL(t.SuspectDOS_PK, 0) = ISNULL(s.SuspectDOS_PK, 0)
            AND ( ISNULL(t.DOS_From, '') <> ISNULL(s.DOS_From, '')
                  OR ISNULL(t.DOS_To, '') <> ISNULL(s.DOS_To, '')
                )
        WHEN MATCHED THEN
            UPDATE SET
                    t.SuspectDOS_PK = s.SuspectDOS_PK ,
                    t.DOS_From = s.DOS_From ,
                    t.DOS_To = s.DOS_To ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( SuspectID ,
                     SuspectDOS_PK ,
                     DOS_From ,
                     DOS_To                   
					
                   )
            VALUES ( SuspectID ,
                     SuspectDOS_PK ,
                     DOS_From ,
                     DOS_To
                   );

    END;     


GO
