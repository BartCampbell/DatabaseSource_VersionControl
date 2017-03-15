SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblUserProjectHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadUserProjectHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadUserProjectHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
INSERT INTO adv.tblUserProjectHash
        ( HashDiff )
SELECT upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
RTRIM(LTRIM(COALESCE(a.User_PK,''))),':',
RTRIM(LTRIM(COALESCE(a.Project_PK,''))),':',
RTRIM(LTRIM(COALESCE(a.Client,'')))


))
			),2))
FROM adv.tblUserProjectStage a
LEFT OUTER JOIN adv.tblUserProjectHash b
ON 		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
RTRIM(LTRIM(COALESCE(a.User_PK,''))),':',
RTRIM(LTRIM(COALESCE(a.Project_PK,''))),':',
RTRIM(LTRIM(COALESCE(a.Client,'')))
))
			),2)) = b.HashDiff
			WHERE b.HashDiff IS NULL
    END;
GO
