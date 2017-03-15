SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectScanningNotesHash  @CCI INT
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectScanningNotesHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ScanningNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblSuspectScanningNotes' ,
                        @Date
                FROM    adv.tblSuspectScanningNotesStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.ScanningNote_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblSuspectScanningNotes'
                WHERE   b.HashDiff IS NULL;






    END;
GO
