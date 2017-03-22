SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
--Update adding new columns for Advance updates 02282017 PDJ
-- Description:	Loads the ContactNote staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadContactNoteHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadContactNoteHash]
    @CCI INT ,
    @Date DATETIME
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNote_Text,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsSystem,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sortOrder,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsIssue,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCNA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsFollowup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Followup_days,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsActive,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCopyCenter,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsRetro,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsProspective,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDataIssue,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AllowedAttempts,
																 ''))), ':',
																RTRIM(LTRIM(COALESCE(a.ChaseStatus_PK,
																 ''))), ':',
																RTRIM(LTRIM(COALESCE(a.IsContact,
																 ''))), ':',
																RTRIM(LTRIM(COALESCE(a.ContactNoteID ,
																 ''))), ':',
																RTRIM(LTRIM(COALESCE(a.IsIssueLogResponse,
																 ''))), ':',
																RTRIM(LTRIM(COALESCE(a.ProviderOfficeSubBucket_PK,
                                                              '')))
															  ))), 2)) ,
                        @CCI ,
                        'tblContactNote' ,
                        @Date,
						@recordsource
                FROM    adv.tblContactNoteStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNote_Text,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsSystem,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sortOrder,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsIssue,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCNA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsFollowup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Followup_days,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsActive,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsCopyCenter,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsRetro,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsProspective,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDataIssue,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AllowedAttempts,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.ChaseStatus_PK,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.IsContact,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.ContactNoteID ,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.IsIssueLogResponse,
                                                              ''))), ':',
															  RTRIM(LTRIM(COALESCE(a.ProviderOfficeSubBucket_PK,
                                                              '')))
															  ))), 2))  = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblContactNote'
															 AND b.RecordSource =  @recordsource
                WHERE   b.HashDiff IS NULL;


    END;


GO
