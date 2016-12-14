SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblUserSessionLogHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadUserSessionLogHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadUserSessionLogHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        INSERT  INTO adv.tblUserSessionLogHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Session_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AccessedPage,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CONVERT(VARCHAR(25), a.AccessedDate, 109),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblUserSessionLogStage a
                        LEFT OUTER JOIN adv.tblUserSessionLogHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Session_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AccessedPage,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(CONVERT(VARCHAR(25), a.AccessedDate, 109),
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;

    END;
GO
