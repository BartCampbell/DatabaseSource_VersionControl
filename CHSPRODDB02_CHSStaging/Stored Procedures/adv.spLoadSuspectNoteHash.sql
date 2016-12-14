SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblSuspectNoteHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectNoteHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectNoteHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblSuspectNoteHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblSuspectNoteStage a
                        LEFT OUTER JOIN adv.tblSuspectNoteHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Coded_Date,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;




    END;
GO
