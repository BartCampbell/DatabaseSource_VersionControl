SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the IssueResponse staging data to StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadIssueResponseHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadIssueResponseHash]
    @CCI INT ,
    @DATE DATETIME
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[IssueResponse_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.[IssueResponse],
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblIssueResponse' ,
                        @DATE
                FROM    adv.tblIssueResponseStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[IssueResponse_PK],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.[IssueResponse],
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblIssueResponse'
                WHERE   b.HashDiff IS NULL;


    END;
GO
