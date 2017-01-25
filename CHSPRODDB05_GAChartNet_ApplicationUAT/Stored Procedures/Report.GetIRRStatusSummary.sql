SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetIRRStatusSummary]
(
	@AbstractorID int = NULL,
	@AbstractionReviewSetRangeStartDate datetime = NULL,
	@AbstractionReviewSetRangeEndDate datetime = NULL,
	@AbstractionReviewSetID int = NULL,
	@AbstractionReviewStatusID int = NULL,
	@FilterOnUserName bit = 0,
	@MeasureComponentID int = NULL,
	@MeasureID int = NULL,
	@PursuitCategory varchar(50) = NULL,
	@ReviewerID int = NULL,
	@ShowCompletedReviewsOnly bit = 0,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @AbstractionReviewSetID = -1
		SET @AbstractionReviewSetID = dbo.GetMostRecentAbstractionReviewSet();

	SET @PursuitCategory = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@PursuitCategory, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');

    WITH Deductions AS
	(
		SELECT	AbstractionReviewID,
				SUM(Deductions) AS Deductions
		FROM	dbo.AbstractionReviewDetail WITH(NOLOCK)
		GROUP BY AbstractionReviewID
	),
	Reviews AS
	(
		SELECT	R.AbstractionDate,
				R.AbstractorID,
				AR.AbstractionReviewID,
				AR.AbstractionReviewSetConfigID,
				ARS.EndDate AS AbstractionReviewSetEndDate,
				ARS.StartDate AS AbstractionReviewSetStartDate,
				ARS.AbstractionReviewSetID,
				AR.AbstractionReviewStatusID,
				RV.AbstractionStatusID,
				ARD.CountCriticalFixed,
                ARD.CountCriticalNotFixed,
                ARD.CountNotCriticalFixed,
                ARD.CountNotCriticalNotFixed,
				ISNULL(ARD.FixNeeded, 0) AS FixNeeded,
				ISNULL(ARD.HasCritical, 0) AS HasCritical,
				ARST.IsCanceled,
				ARST.IsCompleted, 
				AR.MeasureComponentID,
				RV.MeasureID,
				R.MemberID,
				CASE WHEN ARST.IsCompleted = 0 OR ISNULL(D.Deductions, 0) > AR.ReviewPointsAvailable THEN 0 ELSE AR.ReviewPointsAvailable - ISNULL(D.Deductions, 0) END AS PointsActual,
				CASE WHEN ARST.IsCompleted = 0 THEN 0 ELSE AR.ReviewPointsAvailable END AS PointsAvailable,
				RV.PursuitEventID,
				R.PursuitID,
				AR.ReviewDate,
				AR.ReviewerID
		FROM	dbo.AbstractionReview AS AR WITH(NOLOCK)
				LEFT OUTER JOIN dbo.AbstractionReviewSetConfiguration AS ARSC WITH(NOLOCK)
						ON ARSC.AbstractionReviewSetConfigID = AR.AbstractionReviewSetConfigID
				LEFT OUTER JOIN dbo.AbstractionReviewSet ARS WITH(NOLOCK)
						ON ARS.AbstractionReviewSetID = ARSC.AbstractionReviewSetID
				INNER JOIN dbo.AbstractionReviewStatus AS ARST WITH(NOLOCK)
						ON ARST.AbstractionReviewStatusID = AR.AbstractionReviewStatusID
				INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
						ON AR.PursuitEventID = RV.PursuitEventID
				INNER JOIN dbo.Pursuit AS R WITH(NOLOCK)
						ON RV.PursuitID = R.PursuitID
				LEFT OUTER JOIN Deductions AS D
						ON AR.AbstractionReviewID = D.AbstractionReviewID
				OUTER APPLY (SELECT MAX(CASE WHEN tARD.IsFixed = 0 THEN 1 ELSE 0 END) AS FixNeeded, MAX(CASE WHEN tARD.IsCritical = 1 THEN 1 ELSE 0 END) AS HasCritical, SUM(CASE WHEN tARD.IsCritical = 1 AND tARD.IsFixed = 1 THEN 1 ELSE 0 END) AS CountCriticalFixed, SUM(CASE WHEN tARD.IsCritical = 1 AND tARD.IsFixed = 0 THEN 1 ELSE 0 END) AS CountCriticalNotFixed, SUM(CASE WHEN tARD.IsCritical = 0 AND tARD.IsFixed = 1 THEN 1 ELSE 0 END) AS CountNotCriticalFixed, SUM(CASE WHEN tARD.IsCritical = 0 AND tARD.IsFixed = 0 THEN 1 ELSE 0 END) AS CountNotCriticalNotFixed FROM dbo.AbstractionReviewDetail AS tARD WITH(NOLOCK) WHERE tARD.AbstractionReviewID = AR.AbstractionReviewID) AS ARD
		WHERE	((@PursuitCategory IS NULL) OR (R.PursuitCategory LIKE @PursuitCategory))
	),
	Pursuits AS
	(
		SELECT	R.AbstractorID,
				COUNT(DISTINCT CASE WHEN AST.IsCompleted = 1 THEN RV.PursuitID END) AS CountCompleted,
				COUNT(DISTINCT RV.PursuitID) AS CountRecords,
				MC.MeasureComponentID,
				RV.MeasureID
		FROM	dbo.Pursuit AS R WITH(NOLOCK)
				INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK)
						ON MC.MeasureID = RV.MeasureID
				INNER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
						ON AST.AbstractionStatusID = RV.AbstractionStatusID
		WHERE	(MC.EnabledOnWebsite = 1 AND MC.EnabledOnReviews = 1) AND
				((@PursuitCategory IS NULL) OR (R.PursuitCategory LIKE @PursuitCategory))
		GROUP BY R.AbstractorID,
				RV.MeasureID,
				MC.MeasureComponentID
	),
	Results AS
	(
		SELECT	--MIN(ISNULL(A.AbstractorID, -1)) AS AbstractorID,
				--MIN(ISNULL(A.AbstractorName, '(Unassigned)')) AS AbstractorName,
				MIN(ARST.[Description]) AS AbstractionReviewStatusDescription,
				MIN(V.AbstractionReviewStatusID) AS AbstractionReviewStatusID,
				MIN(P.CountCompleted) AS CountCompleted, 
				COUNT(DISTINCT V.PursuitID) AS CountPursuitReviewed,
				MIN(P.CountRecords) AS CountPursuits,
				COUNT(DISTINCT V.AbstractionReviewID) AS CountReviews,
				ISNULL(COUNT(DISTINCT CASE WHEN V.IsCompleted = 1 THEN V.AbstractionReviewID END), 0) AS CountReviewCompleted,
				ISNULL(COUNT(DISTINCT CASE WHEN V.IsCompleted = 0 THEN V.AbstractionReviewID END), 0) AS CountReviewNotCompleted,
				ISNULL(SUM(V.CountCriticalFixed), 0) AS CountReviewDetailCriticalFixed,
				ISNULL(SUM(V.CountCriticalNotFixed), 0) AS CountReviewDetailCriticalNotFixed,
				ISNULL(SUM(V.CountNotCriticalFixed), 0) AS CountReviewDetailNotCriticalFixed,
				ISNULL(SUM(V.CountNotCriticalNotFixed), 0) AS CountReviewDetailNotCriticalNotFixed,
				MIN(M.HEDISMeasure) AS MeasureAbbrev,
				MIN(MC.Title) AS MeasureComponentDescr,
				MIN(MC.MeasureComponentID) AS MeasureComponentID,
				MIN(MC.ComponentName) AS MeasureComponentName,
				MIN(M.HEDISMeasureDescription) AS MeasureDescr,
				MIN(M.MeasureID) AS MeasureID,
				MIN(M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription) AS MeasureLongDescr,
				ISNULL(SUM(V.PointsActual), 0) AS PointsActual,
				ISNULL(SUM(V.PointsAvailable), 0) AS PointsAvailable
		FROM	Pursuits AS P
				INNER JOIN Reviews AS V
						ON P.AbstractorID = V.AbstractorID AND
							V.MeasureComponentID = P.MeasureComponentID AND
							P.MeasureID = V.MeasureID
				LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
						ON P.AbstractorID = A.AbstractorID
				INNER JOIN dbo.Measure AS M WITH(NOLOCK)
						ON P.MeasureID = M.MeasureID
				INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK)
						ON P.MeasureComponentID = MC.MeasureComponentID
				LEFT OUTER JOIN dbo.Reviewer AS R WITH(NOLOCK)
						ON R.ReviewerID = V.ReviewerID
				LEFT OUTER JOIN dbo.AbstractionReviewStatus AS ARST WITH(NOLOCK)
						ON ARST.AbstractionReviewStatusID = V.AbstractionReviewStatusID
		WHERE	((@AbstractorID IS NULL) OR (P.AbstractorID = @AbstractorID) OR (P.AbstractorID IS NULL AND @AbstractorID = -1)) AND
				(
					(
						(@AbstractionReviewSetRangeStartDate IS NULL) AND 
						(@AbstractionReviewSetRangeEndDate IS NULL)
					) OR 
					(
						(
							(@AbstractionReviewSetRangeStartDate IS NOT NULL) OR 
							(@AbstractionReviewSetRangeEndDate IS NOT NULL)
						) AND
						(V.AbstractionReviewSetStartDate BETWEEN ISNULL(@AbstractionReviewSetRangeStartDate, 0) AND ISNULL(@AbstractionReviewSetRangeEndDate, GETDATE())) AND
						(V.AbstractionReviewSetEndDate BETWEEN ISNULL(@AbstractionReviewSetRangeStartDate, 0) AND ISNULL(@AbstractionReviewSetRangeEndDate, GETDATE()))
					)
				) AND
				((@AbstractionReviewSetID IS NULL) OR (V.AbstractionReviewSetID = @AbstractionReviewSetID)) AND
				((@AbstractionReviewStatusID IS NULL) OR (V.AbstractionReviewStatusID = @AbstractionReviewStatusID)) AND
				((@MeasureComponentID IS NULL) OR (P.MeasureComponentID = @MeasureComponentID)) AND
				((@MeasureID IS NULL) OR (P.MeasureID = @MeasureID)) AND
				((@ReviewerID IS NULL) OR (V.ReviewerID = @ReviewerID) OR (@ReviewerID = -1 AND V.ReviewerID = NULL)) AND
				(
					(@UserName IS NULL) OR 
					(ISNULL(@FilterOnUserName, 0) = 0) OR 
					(A.UserName = @UserName) OR
					(R.UserName = @UserName)
				) AND
				((ISNULL(@ShowCompletedReviewsOnly, 0) = 0) OR (V.IsCompleted = 1) OR (V.IsCanceled = 1))
		GROUP BY V.AbstractionReviewStatusID,
				M.MeasureID,
				MC.MeasureComponentID
	)
	SELECT	CONVERT(int, @AbstractorID) AS AbstractorID,
			CONVERT(int, @ReviewerID) AS ReviewerID,
			MIN(t.AbstractionReviewStatusDescription) AS AbstractionReviewStatusDescription,
            MIN(t.AbstractionReviewStatusID) AS AbstractionReviewStatusID,
            SUM(t.CountCompleted) AS CountCompleted,
            SUM(t.CountPursuitReviewed) AS CountPursuitReviewed,
            SUM(t.CountPursuits) AS CountPursuits,
			SUM(t.CountReviews) AS CountReviews,
            SUM(t.CountReviewCompleted) AS CountReviewCompleted,
            SUM(t.CountReviewNotCompleted) AS CountReviewNotCompleted,
            SUM(t.CountReviewDetailCriticalFixed) AS CountReviewDetailCriticalFixed,
            SUM(t.CountReviewDetailCriticalNotFixed) AS CountReviewDetailCriticalNotFixed,
            SUM(t.CountReviewDetailNotCriticalFixed) AS CountReviewDetailNotCriticalFixed,
            SUM(t.CountReviewDetailNotCriticalNotFixed) AS CountReviewDetailNotCriticalNotFixed,
            '' AS MeasureAbbrev,
            '' AS MeasureComponentDescr,
            CONVERT(int, NULL) AS MeasureComponentID,
            '' AS MeasureComponentName,
            '' AS MeasureDescr,
            CONVERT(int, NULL) AS MeasureID,
            'Total of All Measures/Components' AS MeasureLongDescr,
            SUM(t.PointsActual) AS PointsActual,
            SUM(t.PointsAvailable) AS PointsAvailable,
			1 AS SortOrder 
	FROM	Results AS t
			--CROSS APPLY (SELECT MIN(ta.MeasureComponentID) AS MeasureComponentID FROM Results AS ta WHERE ta.AbstractionReviewStatusID = t.AbstractionReviewStatusID GROUP BY ta.MeasureID) AS a
	WHERE	--t.MeasureComponentID = a.MeasureComponentID AND
			@MeasureComponentID  IS NULL AND
			@MeasureID IS NULL
	GROUP BY AbstractionReviewStatusID
	UNION ALL
	SELECT	CONVERT(int, @AbstractorID) AS AbstractorID,
			CONVERT(int, @ReviewerID) AS ReviewerID,
			t.AbstractionReviewStatusDescription,
            t.AbstractionReviewStatusID,
            t.CountCompleted,
            t.CountPursuitReviewed,
            t.CountPursuits,
			t.CountReviews,
            t.CountReviewCompleted,
            t.CountReviewNotCompleted,
            t.CountReviewDetailCriticalFixed,
            t.CountReviewDetailCriticalNotFixed,
            t.CountReviewDetailNotCriticalFixed,
            t.CountReviewDetailNotCriticalNotFixed,
            t.MeasureAbbrev,
            t.MeasureComponentDescr,
            t.MeasureComponentID,
            t.MeasureComponentName,
            t.MeasureDescr,
            t.MeasureID,
            t.MeasureLongDescr,
            t.PointsActual,
            t.PointsAvailable,
			2 AS SortOrder
	FROM	Results AS t
	ORDER BY MeasureAbbrev, 
			MeasureComponentName
	OPTION	(OPTIMIZE FOR UNKNOWN);
		
END

GO
GRANT EXECUTE ON  [Report].[GetIRRStatusSummary] TO [Reporting]
GO
