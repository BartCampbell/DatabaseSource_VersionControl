SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the ExtractionQueue staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadExtractionQueueHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadExtractionQueueHash]
    @CCI INT ,
    @DATE DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @recordsource VARCHAR(20)
	SET @recordsource =(SELECT TOP 1 RecordSource FROM adv.AdvanceVariables WHERE  AVKey =(SELECT TOP 1 VariableLoadKey FROM adv.AdvanceVariableLoad))
     
      
        
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate,
				  RecordSource
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblExtractionQueue' ,
                        @DATE,
						@recordsource
                FROM    adv.tblExtractionQueueStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ExtractionQueue_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PDFname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ExtractionQueueSource_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.FileSize,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedUser_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDuplicate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.UploadDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AssignedDate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.OfficeFaxOrID,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblExtractionQueue'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;


    END;
GO
