SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/14/2016
-- Description:	Loads the StagingHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadNoteTextHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadNoteTextHash]
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
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDiagnosisNote,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsChartNote,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteType,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteType_PK,
                                                              '')))))), 2)) ,
                        @CCI ,
                        'tblNoteText' ,
                        @Date
                FROM    adv.tblNoteTextStage a
                        LEFT OUTER JOIN adv.StagingHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsDiagnosisNote,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsChartNote,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteType,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteType_PK,
                                                              '')))))), 2)) = b.HashDiff
                                                             AND b.ClientID = @CCI
                                                             AND b.TableName = 'tblNoteText'
                WHERE   b.HashDiff IS NULL;


    END;
GO
