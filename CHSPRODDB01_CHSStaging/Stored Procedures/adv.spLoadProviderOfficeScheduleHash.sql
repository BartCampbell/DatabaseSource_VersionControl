SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadProviderOfficeScheduleHash @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadProviderOfficeScheduleHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOfficeSchedule_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_Start,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_End,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.followup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AddInfo,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sch_type,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblProviderOfficeSchedule' ,
                        @Date,
						@recordsource
                FROM    adv.tblProviderOfficeScheduleStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ProviderOfficeSchedule_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Project_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ProviderOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_Start,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_End,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Sch_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.followup,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AddInfo,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.sch_type,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblProviderOfficeSchedule'
															 AND b.RecordSource = @recordsource
                WHERE   b.HashDiff IS NULL;






    END;
GO
