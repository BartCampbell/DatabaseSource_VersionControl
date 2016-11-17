SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblCodedDataNoteHash with the hashdiff key
-- Usage		EXECUTE adv.sp_LoadCodedDataNotehash
-- =============================================
CREATE PROCEDURE [adv].[spLoadCodedDataNoteHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        
        
        INSERT  INTO adv.tblCodedDataNoteHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CodedData_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblCodedDataNoteStage a
                        LEFT OUTER JOIN adv.tblCodedDataNoteHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CodedData_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.NoteText_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;
    END;
GO
