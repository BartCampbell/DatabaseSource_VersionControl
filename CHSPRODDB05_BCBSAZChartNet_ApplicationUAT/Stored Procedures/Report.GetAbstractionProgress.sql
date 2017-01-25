SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractionProgress]
(
	@AbstractorID int = NULL,
	@MeasureID int = NULL,
	@Product varchar(20) = NULL,
	@ProductLine varchar(20) = NULL,
	-----------------------------------------------
	@FilterOnUserName bit = 0,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    WITH PlaceHolderStatuses(AbstractionStatusID, [Description], IsCompleted) AS
	(  
		SELECT	0, NULL, 0
		UNION
	    SELECT	1, NULL, 0
		UNION
		SELECT	5, NULL, 0 
		UNION
		SELECT	10, NULL, 0 
		UNION
		SELECT	15, NULL, 0 
		UNION
		SELECT	20, NULL, 0 
		UNION
		SELECT	25, NULL, 0 
		UNION
		SELECT	30, NULL, 0 
		UNION
		SELECT	35, NULL, 0 
	),
	AbstractionStatusDescriptions AS
	(
		-- Description of NULL hides the column on the report
		SELECT	[0] AS Descr00,
				[1] AS Descr01,
				[5] AS Descr05,
				[10] AS Descr10,
				[15] AS Descr15,
				[20] AS Descr20,
				[25] AS Descr25,
				[30] AS Descr30,
				[35] AS Descr35
		FROM	(
					SELECT	AbstractionStatusID,
					        [Description]
					FROM	dbo.AbstractionStatus WITH(NOLOCK)
					UNION
					SELECT	AbstractionStatusID,
					        [Description]
					FROM	PlaceHolderStatuses WITH(NOLOCK)
					WHERE	AbstractionStatusID NOT IN (SELECT AbstractionStatusID FROM dbo.AbstractionStatus WITH(NOLOCK))  
					              
				) AS p
				PIVOT
				(
					MIN(p.Description)
					FOR p.AbstractionStatusID IN
					([0], [1], [5], [10], [15], [20], [25], [30], [35])
				) AS pvt
	),
	ChartStatusDescription AS
	(
		-- Description of NULL hides the column on the report
		SELECT	-1 AS ChartStatusValueIDChartField1,
				1 AS ChartStatusValueIDChartField2,
				2 AS ChartStatusValueIDChartField3,
				5 AS ChartStatusValueIDChartField4,
				3 AS ChartStatusValueIDChartField5,
				'No Status' AS DescrChartField1,
				'Found' AS DescrChartField2,
				'Not Found' AS DescrChartField3,
				/*'Archived'*/NULL AS DescrChartField4,
				/*'Unavailable'*/NULL AS DescrChartField5
	),
	ChartStatusBase AS
	(
		SELECT	P.AbstractorID,
				MIN(ISNULL((NULLIF(NULLIF(CSV.Title, ''), '(None)')), 'None')) AS ChartStatus,
				ISNULL(PS.ChartStatusValueID, -1) AS ChartStatusValueID,
				COUNT(DISTINCT PS.PursuitEventID) AS CountRecords,
				PS.MeasureID
		FROM	dbo.Pursuit AS P WITH(NOLOCK)
				INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
						ON MBR.MemberID = P.MemberID
				INNER JOIN dbo.PursuitEvent AS PS WITH(NOLOCK)
						ON P.PursuitID = PS.PursuitID
				LEFT OUTER JOIN dbo.ChartStatusValue AS CSV WITH(NOLOCK)
						ON PS.ChartStatusValueID = CSV.ChartStatusValueID
		WHERE	((@ProductLine IS NULL) OR (MBR.ProductLine = @ProductLine)) AND
				((@Product IS NULL) OR (MBR.Product = @Product))
		GROUP BY P.AbstractorID,
				PS.ChartStatusValueID,
				PS.MeasureID
	),
	ChartStatus AS
	(
		SELECT	AbstractorID,
				SUM(CountRecords) AS CountRecords,
				ISNULL(SUM([None]), 0) AS CountChartField1,
				ISNULL(SUM([Data found]), 0) + ISNULL(SUM([Found]), 0) AS CountChartField2,
				ISNULL(SUM([No data found]), 0) + ISNULL(SUM([Not found]), 0) AS CountChartField3,
				ISNULL(SUM([Medical record archived]), 0) AS CountChartField4, 
				ISNULL(SUM([Medical record unavailable]), 0) AS CountChartField5,
				MeasureID
		FROM	(
					SELECT	AbstractorID,			        
							ChartStatus,
							CountRecords,
							CountRecords AS CountSource,
							MeasureID
					FROM	ChartStatusBase
				) AS p
				PIVOT
				(
					SUM(CountSource)
					FOR p.ChartStatus IN
					([Medical record archived], [Data found], [No data found], [None], [Medical record unavailable], [Found], [Not Found])
				) AS pvt
		GROUP BY AbstractorID,
				MeasureID	
	),
	PursuitStatusBase AS
	(
		SELECT	AST.AbstractionStatusID,
				P.AbstractorID,
				COUNT(DISTINCT PS.PursuitEventID) AS CountRecords,
				PS.MeasureID
		FROM	dbo.Pursuit AS P WITH(NOLOCK)
				INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
						ON MBR.MemberID = P.MemberID
				INNER JOIN dbo.PursuitEvent AS PS WITH(NOLOCK)
						ON P.PursuitID = PS.PursuitID
				INNER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
						ON PS.AbstractionStatusID = AST.AbstractionStatusID
		WHERE	((@ProductLine IS NULL) OR (MBR.ProductLine = @ProductLine)) AND
				((@Product IS NULL) OR (MBR.Product = @Product))
		GROUP BY P.AbstractorID,
				--PS.ChartStatus, 
				PS.MeasureID, 
				AST.AbstractionStatusID
	),
	PursuitStatus AS
	(
		SELECT	AbstractorID,
				SUM(CountRecords) AS CountRecords,  
				ISNULL(SUM([0]), 0) AS CountRecords00,
				ISNULL(SUM([1]), 0) AS CountRecords01,
				ISNULL(SUM([5]), 0) AS CountRecords05,
				ISNULL(SUM([10]), 0) AS CountRecords10,
				ISNULL(SUM([15]), 0) AS CountRecords15,
				ISNULL(SUM([20]), 0) AS CountRecords20,
				ISNULL(SUM([25]), 0) AS CountRecords25,
				ISNULL(SUM([30]), 0) AS CountRecords30,
				ISNULL(SUM([35]), 0) AS CountRecords35,
				MeasureID
		FROM	(
					SELECT	AbstractionStatusID,
							AbstractorID,			        
							CountRecords,
							CountRecords AS CountSource,
							MeasureID
					FROM	PursuitStatusBase
				) AS p
				PIVOT
				(
					SUM(CountSource)
					FOR p.AbstractionStatusID IN
					([0], [1], [5], [10], [15], [20], [25], [30], [35])
				) AS pvt
		GROUP BY AbstractorID,
				MeasureID
	),
	PursuitEventsWithCharts AS
	(
		SELECT DISTINCT PursuitEventID FROM dbo.PursuitEventChartImage WITH(NOLOCK)
	),
	PursuitEventsWithReviews AS
	(
		SELECT DISTINCT PursuitEventID FROM dbo.AbstractionReview WITH(NOLOCK)
	),
	MeasurePursuits AS
	(
		SELECT	COUNT(DISTINCT PSWC.PursuitEventID) AS CountChartScans,
				COUNT(DISTINCT PS.PursuitEventID) AS CountPursuits,
				COUNT(DISTINCT PSWR.PursuitEventID) AS CountReviews,
				PS.MeasureID
		FROM	dbo.Pursuit AS P WITH(NOLOCK)
				INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
						ON MBR.MemberID = P.MemberID
				INNER JOIN dbo.PursuitEvent AS PS WITH(NOLOCK)
						ON P.PursuitID = PS.PursuitID
				LEFT OUTER JOIN PursuitEventsWithCharts AS PSWC WITH(NOLOCK)
						ON PS.PursuitEventID = PSWC.PursuitEventID
				LEFT OUTER JOIN PursuitEventsWithReviews AS PSWR WITH(NOLOCK)
						ON PS.PursuitEventID = PSWR.PursuitEventID
				INNER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
						ON ISNUMERIC(PS.PursuitEventStatus) = 1 AND
							CONVERT(int, PS.PursuitEventStatus) = AST.AbstractionStatusID
		WHERE	((@ProductLine IS NULL) OR (MBR.ProductLine = @ProductLine)) AND
				((@Product IS NULL) OR (MBR.Product = @Product))
		GROUP BY PS.MeasureID
	),
	MeasureAbstractorPursuits AS
	(
		SELECT	P.AbstractorID,
				COUNT(DISTINCT PSWC.PursuitEventID) AS CountChartScans,
				COUNT(DISTINCT PS.PursuitEventID) AS CountPursuits,
				COUNT(DISTINCT PSWR.PursuitEventID) AS CountReviews,
				PS.MeasureID
		FROM	dbo.Pursuit AS P WITH(NOLOCK)
				INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
						ON MBR.MemberID = P.MemberID
				INNER JOIN dbo.PursuitEvent AS PS WITH(NOLOCK)
						ON P.PursuitID = PS.PursuitID
				LEFT OUTER JOIN PursuitEventsWithCharts AS PSWC WITH(NOLOCK)
						ON PS.PursuitEventID = PSWC.PursuitEventID
				LEFT OUTER JOIN PursuitEventsWithReviews AS PSWR WITH(NOLOCK)
						ON PS.PursuitEventID = PSWR.PursuitEventID
				INNER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
						ON ISNUMERIC(PS.PursuitEventStatus) = 1 AND
							CONVERT(int, PS.PursuitEventStatus) = AST.AbstractionStatusID
		WHERE	((@ProductLine IS NULL) OR (MBR.ProductLine = @ProductLine)) AND
				((@Product IS NULL) OR (MBR.Product = @Product))
		GROUP BY P.AbstractorID,
				PS.MeasureID
	)
	SELECT	ISNULL(PS.AbstractorID, -1) AS AbstractorID,
			ISNULL(A.AbstractorName, '(Unassigned)') AS AbstractorName,
			CS.CountChartField1,
			CS.CountChartField2,
			CS.CountChartField3,
			CS.CountChartField4,
			CS.CountChartField5,
			MAP.CountChartScans,
			MP.CountPursuits,
			PS.CountRecords,
			PS.CountRecords00,
			PS.CountRecords01,
			PS.CountRecords05,
			PS.CountRecords10,
			PS.CountRecords15,
			PS.CountRecords20,
			PS.CountRecords25,
			PS.CountRecords30,
			PS.CountRecords35,
			MAP.CountReviews,
			ASD.Descr00,
			ASD.Descr01,
			ASD.Descr05,
			ASD.Descr10,
			ASD.Descr15,
			ASD.Descr20,
			ASD.Descr25,
			ASD.Descr30,
			ASD.Descr35,
			CSD.*,
			'Scanned' AS DescrChartScanned,
			'Reviewed' AS DescrReviews,
			M.HEDISMeasure AS MeasureAbbrev,
			PS.MeasureID,
			M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription AS MeasureLongDescr
	FROM	PursuitStatus AS PS
			INNER JOIN ChartStatus AS CS
					ON PS.MeasureID = CS.MeasureID AND
						(PS.AbstractorID = CS.AbstractorID OR (PS.AbstractorID IS NULL AND CS.AbstractorID IS NULL))
			INNER JOIN MeasurePursuits AS MP
					ON PS.MeasureID = MP.MeasureID
			INNER JOIN MeasureAbstractorPursuits AS MAP
					ON PS.MeasureID = MAP.MeasureID AND
						(PS.AbstractorID = MAP.AbstractorID OR (PS.AbstractorID IS NULL AND MAP.AbstractorID IS NULL))
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON PS.MeasureID = M.MeasureID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
						ON PS.AbstractorID = A.AbstractorID
			CROSS JOIN AbstractionStatusDescriptions AS ASD
			CROSS JOIN ChartStatusDescription AS CSD
	WHERE	((@AbstractorID IS NULL) OR (PS.AbstractorID = @AbstractorID) OR (PS.AbstractorID IS NULL AND @AbstractorID = -1)) AND
			((@MeasureID IS NULL) OR (PS.MeasureID = @MeasureID)) AND
			(
				(@UserName IS NULL) OR 
				(ISNULL(@FilterOnUserName, 0) = 0) OR 
				(A.UserName = @UserName) 
			) 
	ORDER BY MeasureAbbrev, AbstractorName
	OPTION	(OPTIMIZE FOR (@AbstractorID = NULL, @MeasureID = NULL));
		
END
GO
GRANT EXECUTE ON  [Report].[GetAbstractionProgress] TO [Reporting]
GO
