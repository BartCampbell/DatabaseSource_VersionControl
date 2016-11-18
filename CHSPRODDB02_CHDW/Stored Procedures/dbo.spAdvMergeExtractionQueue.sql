SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
--Update 9/20/2016 for WellCare PJ
-- Description:	merges the stage to dim for advance ExtractionQueue 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeExtractionQueue
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeExtractionQueue]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.ExtractionQueue AS t
        USING
            ( SELECT    ps.CentauriExtractionQueueID ,
                        sp.UserID AS Assigned_UserID ,
                        ps.PDFname ,
                        ps.ExtractionQueueSource_PK ,
                        ps.FileSize ,
                        ps.IsDuplicate ,
                        ps.UploadDate ,
                        ps.AssignedDate ,
                        ps.OfficeFaxOrID
              FROM      [stage].[ExtractionQueue_ADV] ps
                        LEFT OUTER JOIN [dim].[User] sp ON sp.CentauriUserID = ps.Assigned_CentauriUserID) AS s
        ON t.CentauriExtractionQueueID = s.CentauriExtractionQueueID
        WHEN MATCHED AND ( ISNULL(t.Assigned_UserID, '') <> ISNULL(s.Assigned_UserID,
                                                              '')
                           OR ISNULL(t.PDFname, 0) <> ISNULL(s.PDFname, 0)
                           OR ISNULL(t.ExtractionQueueSource_PK, 0) <> ISNULL(s.ExtractionQueueSource_PK,
                                                              0)
                           OR ISNULL(t.FileSize, 0) <> ISNULL(s.FileSize, 0)
                           OR ISNULL(t.IsDuplicate, 0) <> ISNULL(s.IsDuplicate,
                                                              0)
                           OR ISNULL(t.UploadDate, '') <> ISNULL(s.UploadDate,
                                                              '')
                           OR ISNULL(t.AssignedDate, '') <> ISNULL(s.AssignedDate,
                                                              '')
                           OR ISNULL(t.OfficeFaxOrID, '') <> ISNULL(s.OfficeFaxOrID,
                                                              '')
                         ) THEN
            UPDATE SET
                    t.Assigned_UserID = s.Assigned_UserID ,
                    t.PDFname = s.PDFname ,
                    t.ExtractionQueueSource_PK = s.ExtractionQueueSource_PK ,
                    t.FileSize = s.FileSize ,
                    t.IsDuplicate = s.IsDuplicate ,
                    t.UploadDate = s.UploadDate ,
                    t.AssignedDate = s.AssignedDate ,
                    t.OfficeFaxOrID = s.OfficeFaxOrID ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriExtractionQueueID ,
                     Assigned_UserID ,
                     PDFname ,
                     ExtractionQueueSource_PK ,
                     FileSize ,
                     IsDuplicate ,
                     UploadDate ,
                     AssignedDate ,
                     OfficeFaxOrID
                   )
            VALUES ( CentauriExtractionQueueID ,
                     Assigned_UserID ,
                     PDFname ,
                     ExtractionQueueSource_PK ,
                     FileSize ,
                     IsDuplicate ,
                     UploadDate ,
                     AssignedDate ,
                     OfficeFaxOrID
                   );

    END;     

GO
