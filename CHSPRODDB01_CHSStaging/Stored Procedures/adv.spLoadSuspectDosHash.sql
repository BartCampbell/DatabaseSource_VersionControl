SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectDosHash  @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectDosHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.SuspectDOS_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_From,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_To,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblSuspectDOS' ,
                        @Date
                FROM    adv.tblSuspectDOSStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.SuspectDOS_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_From,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.DOS_To,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblSuspectDOS'
                WHERE   b.HashDiff IS NULL;






    END;
GO
