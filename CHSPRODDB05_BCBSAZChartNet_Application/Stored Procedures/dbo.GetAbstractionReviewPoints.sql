SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAbstractionReviewPoints]
(
	@MeasureComponentID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	WITH ReviewPoints AS
	(
		SELECT	ARP.MeasureComponentID, 
				MC.ComponentName, 
				ARP.ReviewPointsAvailable,
				MC.EnabledOnReviews,
				MC.EnabledOnWebsite
		FROM	dbo.AbstractionReviewPoints AS ARP
				INNER JOIN dbo.MeasureComponent AS MC 
						ON ARP.MeasureComponentID = MC.MeasureComponentID
		UNION
		SELECT	MC.MeasureComponentID, 
				MC.ComponentName, 
				DFLT.ReviewPointsAvailable,
				MC.EnabledOnReviews,
				MC.EnabledOnWebsite
		FROM	dbo.MeasureComponent AS MC
				LEFT OUTER JOIN dbo.AbstractionReviewPoints AS ARP
						ON MC.MeasureComponentID = ARP.MeasureComponentID
				OUTER APPLY (SELECT dbo.GetDefaultReviewPointsAvailable() AS ReviewPointsAvailable) AS DFLT
		WHERE	(ARP.MeasureComponentID IS NULL)
	)
	SELECT	*
	FROM	ReviewPoints
	WHERE	((@MeasureComponentID IS NULL) OR (MeasureComponentID = @MeasureComponentID))
	ORDER BY 1
	OPTION	(OPTIMIZE FOR (@MeasureComponentID = NULL));

END
GO
