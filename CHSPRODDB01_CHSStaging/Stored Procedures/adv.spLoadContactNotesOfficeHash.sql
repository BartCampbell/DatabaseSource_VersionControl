SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the ContactNotesOffice staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadContactNotesOfficeHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadContactNotesOfficeHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNotesOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Office_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNoteText,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.contact_num,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.followup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsResponded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsViewedByScheduler,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblContactNotesOffice' ,
                        @Date,
						@recordsource

                FROM    adv.tblContactNotesOfficeStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ContactNotesOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Office_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNoteText,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.contact_num,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.followup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsResponded,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsViewedByScheduler,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblContactNotesOffice'
															 AND b.RecordSource =  @recordsource
                WHERE   b.HashDiff IS NULL;


    END;
GO
