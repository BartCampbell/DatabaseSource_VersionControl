SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadUserRemovedHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadUserRemovedHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.RemovedBy_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Removed_date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Username,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Password,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsSuperUser,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsAdmin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScanTech,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScheduler,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsReviewer,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsQA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsActive,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.only_work_selected_hours,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.only_work_selected_zipcodes,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.deactivate_after,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblUserRemoved' ,
                        @Date,
						@recordsource
                FROM    adv.tblUserRemovedStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.RemovedBy_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Removed_date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Username,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Password,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Lastname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Firstname,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Email_Address,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsSuperUser,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsAdmin,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScanTech,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsScheduler,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsReviewer,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsQA,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsActive,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.only_work_selected_hours,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.only_work_selected_zipcodes,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.deactivate_after,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblUserRemoved'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;

    END;
GO
