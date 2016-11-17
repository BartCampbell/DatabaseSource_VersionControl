SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/15/2016
--Update 09/27/2016 Adding LoadDate to Primary Key PJ
-- Description:	Data Vault NoteType Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ExtractionQueue_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        INSERT  INTO [dbo].[S_ExtractionQueueDetail]
                ( [S_ExtractionQueueDetail_RK] ,
                  [LoadDate] ,
                  [H_ExtractionQueue_RK] ,
                  [PDFname] ,
                  [ExtractionQueueSource_PK] ,
                  [FileSize] ,
                  [IsDuplicate] ,
                  [UploadDate] ,
                  [AssignedDate] ,
                  [OfficeFaxOrID] ,
                  [HashDiff] ,
                  [RecordSource]
					
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CEI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              ''))),':', 
															  RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))
															  ))), 2)) ,
                        LoadDate ,
                        ExtractionQueueHashKey ,
                        [PDFname] ,
                        [ExtractionQueueSource_PK] ,
                        [FileSize] ,
                        [IsDuplicate] ,
                        [UploadDate] ,
                        [AssignedDate] ,
                        [OfficeFaxOrID] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblExtractionQueueStage a WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ExtractionQueueDetail
                        WHERE   H_ExtractionQueue_RK = a.ExtractionQueueHashKey
                                AND RecordEndDate IS NULL )
                        AND a.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CEI,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              ''))),':', 
															  RTRIM(LTRIM(COALESCE(a.[LoadDate], '')))))), 2)) ,
                        LoadDate ,
                        ExtractionQueueHashKey ,
                        [PDFname] ,
                        [ExtractionQueueSource_PK] ,
                        [FileSize] ,
                        [IsDuplicate] ,
                        [UploadDate] ,
                        [AssignedDate] ,
                        [OfficeFaxOrID] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ExtractionQueueDetail
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ExtractionQueueDetail z
                                  WHERE     z.H_ExtractionQueue_RK = a.H_ExtractionQueue_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ExtractionQueueDetail a
        WHERE   RecordEndDate IS NULL; 
	
    END;
    
	
GO
