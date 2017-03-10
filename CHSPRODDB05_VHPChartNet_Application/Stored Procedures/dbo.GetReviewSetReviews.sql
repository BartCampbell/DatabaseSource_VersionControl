SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetReviewSetReviews]
(
 @AbstractionReviewSetID int = 0,
 @AbstractorID int = 0,
 @MeasureComponentID int = 0,
 @ProductLine varchar(20) = '0',
 @Product varchar(20) = '0',
 @ReviewerID int = 0
)
AS
BEGIN

    SET NOCOUNT ON

    SELECT  AR.AbstractionReviewID,
			M.HEDISMeasure AS [Measure],
            M.HEDISMeasure + ' - ' + MC.Title AS [Component],
            R.PursuitNumber AS [PursuitNumber],
            ISNULL(A.AbstractorName, '(Unassigned') AS [Abstractor],
            ISNULL(RVW.ReviewerName, '(Unassigned)') AS [Reviewer],
            RS.Description AS [ReviewStatus]
    FROM    dbo.AbstractionReview AS AR
            INNER JOIN dbo.PursuitEvent AS RV ON AR.PursuitEventID = RV.PursuitEventID
            INNER JOIN dbo.Pursuit AS R ON RV.PursuitID = R.PursuitID
            LEFT OUTER JOIN dbo.Abstractor AS A ON R.AbstractorID = A.AbstractorID
            INNER JOIN dbo.AbstractionReviewStatus AS RS ON AR.AbstractionReviewStatusID = RS.AbstractionReviewStatusID
            INNER JOIN dbo.MeasureComponent AS MC ON AR.MeasureComponentID = MC.MeasureComponentID
            INNER JOIN dbo.Measure AS M ON MC.MeasureID = M.MeasureID
            LEFT OUTER JOIN dbo.Reviewer AS RVW ON AR.ReviewerID = RVW.ReviewerID
			LEFT OUTER JOIN dbo.Member AS MM ON R.MemberID = MM.MemberID
    WHERE   MC.EnabledOnWebsite = 1 -- enabled on website
	  AND   MC.EnabledOnReviews = 1 -- enabled on reviews
	  AND   AR.AbstractionReviewSetConfigID IN (
            SELECT  ARSC.AbstractionReviewSetConfigID
            FROM    dbo.AbstractionReviewSetConfiguration AS ARSC
            WHERE   ARSC.AbstractionReviewSetID = @AbstractionReviewSetID)
			AND (@AbstractorID = 0 OR A.AbstractorID = @AbstractorID)
			AND (@MeasureComponentID = 0 OR MC.MeasureComponentID = @MeasureComponentID)
			AND (@ProductLine = '0' OR MM.ProductLine = @ProductLine)
			AND (@Product = '0' OR MM.Product = @Product)
			AND (
					   (@ReviewerID = -1 AND AR.ReviewerID IS NULL) -- -1 = unassigned
					OR (@ReviewerID = 0) -- 0 = all
					OR (@ReviewerID > 0 AND AR.ReviewerID = @ReviewerID) -- > 0 = selected reviewer
			)
END
GO
