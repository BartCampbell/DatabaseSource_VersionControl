SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the IssueResponseOffice staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadIssueResponseOfficeHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadIssueResponseOfficeHash]
    @CCI INT ,
    @Date DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        
        INSERT  INTO adv.StagingHash
                ( HashDiff ,
                  ClientID ,
                  TableName ,
                  CreateDate
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.IssueResponse_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNotesOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AdditionalResponse,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblIssueResponseOffice' ,
                        @Date
                FROM    adv.tblIssueResponseOfficeStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.IssueResponse_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.ContactNotesOffice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AdditionalResponse,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblIssueResponseOffice'
                WHERE   b.HashDiff IS NULL;


    END;
GO
