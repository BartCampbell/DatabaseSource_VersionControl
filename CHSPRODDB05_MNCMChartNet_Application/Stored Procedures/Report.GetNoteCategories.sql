SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetNoteCategories]
AS
BEGIN

    SET NOCOUNT ON;

    WITH    Results
              AS (SELECT    '(All Note Categories)' AS Descr,
                            CONVERT(int, NULL) AS ID
                  UNION
                  SELECT    ISNULL(RVNCP.Title + ': ', '') + RVNC.Title AS Descr,
                            RVNC.PursuitEventNoteCategoryID AS ID
                  FROM      dbo.PursuitEventNoteCategory AS RVNC WITH(NOLOCK)
                            LEFT OUTER JOIN dbo.PursuitEventNoteCategory AS RVNCP WITH(NOLOCK) ON RVNCP.ParentID = RVNC.PursuitEventNoteCategoryID
                 )
        SELECT  *
        FROM    Results;
    
END


GO
GRANT EXECUTE ON  [Report].[GetNoteCategories] TO [Reporting]
GO
