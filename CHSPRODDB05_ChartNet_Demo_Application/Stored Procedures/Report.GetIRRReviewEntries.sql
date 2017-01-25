SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetIRRReviewEntries]
(
	@AbstractorID int = NULL,
	@AbstractionReviewSetRangeStartDate datetime = NULL,
	@AbstractionReviewSetRangeEndDate datetime = NULL,
	@AbstractionReviewSetID int = NULL,
	@AbstractionReviewStatusID int = NULL,
	@FilterOnUserName bit = 0,
	@IsComplete bit = NULL,
	@IsCritical bit = NULL,
	@IsFixed bit = NULL,
	@MeasureComponentID int = NULL,
	@MeasureID int = NULL,
	@PursuitCategory varchar(50) = NULL,
	@PursuitEventID int = NULL,
	@PursuitID int = NULL,
	@PursuitNumber varchar(20) = NULL,
	@ReviewerID int = NULL,
	@ShowCompletedReviewsOnly bit = 0,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @WebAddress nvarchar(512);
	SELECT @WebAddress = ParamCharValue FROM dbo.SystemParams WITH(NOLOCK) WHERE ParamName = 'WebAddress';

	IF @WebAddress IS NOT NULL AND RIGHT(@WebAddress, 1) <> '/'
		SET @WebAddress = @WebAddress + '/';

	IF @AbstractionReviewSetID = -1
		SET @AbstractionReviewSetID = dbo.GetMostRecentAbstractionReviewSet();

	SET @PursuitCategory = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@PursuitCategory, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @PursuitNumber = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@PursuitNumber, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');

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
				ARD.AbstractionReviewDetailID,
                ARD.Field,
                ARD.IsCritical,
                ARD.[Description],
                ARD.Deductions,
                ARD.IsFixed,
				ARD.IsCriticalFixed,
                ARD.IsCriticalNotFixed,
                ARD.IsNotCriticalFixed,
                ARD.IsNotCriticalNotFixed,
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
				CROSS APPLY (
								SELECT	tARD.AbstractionReviewDetailID,
                                        tARD.Field,
                                        tARD.IsCritical,
                                        tARD.[Description],
                                        tARD.Deductions,
                                        tARD.IsFixed,
										CONVERT(bit, CASE WHEN tARD.IsCritical = 1 AND tARD.IsFixed = 1 THEN 1 ELSE 0 END) AS IsCriticalFixed, 
										CONVERT(bit, CASE WHEN tARD.IsCritical = 1 AND tARD.IsFixed = 0 THEN 1 ELSE 0 END) AS IsCriticalNotFixed, 
										CONVERT(bit, CASE WHEN tARD.IsCritical = 0 AND tARD.IsFixed = 1 THEN 1 ELSE 0 END) AS IsNotCriticalFixed, 
										CONVERT(bit, CASE WHEN tARD.IsCritical = 0 AND tARD.IsFixed = 0 THEN 1 ELSE 0 END) AS IsNotCriticalNotFixed 
								FROM	dbo.AbstractionReviewDetail AS tARD WITH(NOLOCK)
								WHERE	tARD.AbstractionReviewID = AR.AbstractionReviewID
							) AS ARD
		WHERE	((@PursuitCategory IS NULL) OR (R.PursuitCategory LIKE @PursuitCategory))
	)
	SELECT	ISNULL(A.AbstractorID, -1) AS AbstractorID,
			ISNULL(A.AbstractorName, '(Unassigned)') AS AbstractorName,
			ISNULL(R.ReviewerID, -1) AS ReviewerID,
			ISNULL(R.ReviewerName, '(Unassigned)') AS ReviewerName,
			RTRIM(P.PursuitNumber) AS PursuitNumber,
			AST.AbstractionStatusID,
			AST.[Description] AS AbstractionStatusDescription,
			ARST.AbstractionReviewStatusID,
			ARST.[Description] AS AbstractionReviewStatusDescription,
			dbo.ConvertDateToVarchar(ARS.StartDate) + ' - ' + dbo.ConvertDateToVarchar(ARS.EndDate) + ', By: ' + ARS.CreatedUser AS AbsractionReviewSetDescription,
			ARS.AbstractionReviewSetID,
			V.MemberID,
			MBR.CustomerMemberID,
			MBR.NameLast + ISNULL(', ' + MBR.NameFirst, '') + ISNULL(' ' + MBR.NameMiddleInitial, '') AS MemberName,
			MBR.NameLast,
			MBR.NameFirst,
			MBR.DateOfBirth,
			MBR.Gender,
			V.AbstractionReviewDetailID,
            V.Field,
            V.IsCritical,
            V.[Description],
            V.Deductions,
            V.IsFixed,
			V.IsCriticalFixed,
            V.IsCriticalNotFixed,
            V.IsNotCriticalFixed,
            V.IsNotCriticalNotFixed,
			M.HEDISMeasure AS MeasureAbbrev,
			MC.Title AS MeasureComponentDescr,
			MC.TabDisplayTitle AS MeasureComponentTabDescr,
			MC.MeasureComponentID AS MeasureComponentID,
			MC.ComponentName AS MeasureComponentName,
			M.HEDISMeasureDescription AS MeasureDescr,
			M.MeasureID AS MeasureID,
			M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription AS MeasureLongDescr,
			ISNULL(V.PointsActual, 0) AS PointsActual,
			ISNULL(V.PointsAvailable, 0) AS PointsAvailable,
			@WebAddress + 'AbstractionSummary.aspx?id=' + CONVERT(nvarchar(512), V.PursuitEventID) AS WebAddress
	FROM	dbo.Pursuit AS P WITH(NOLOCK)
			INNER JOIN Reviews AS V
					ON V.PursuitID = P.PursuitID
			INNER JOIN dbo.AbstractionReviewStatus AS ARST WITH(NOLOCK)
					ON ARST.AbstractionReviewStatusID = V.AbstractionReviewStatusID
			INNER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
					ON AST.AbstractionStatusID = V.AbstractionStatusID
			LEFT OUTER JOIN dbo.AbstractionReviewSet AS ARS WITH(NOLOCK)
					ON ARS.AbstractionReviewSetID = V.AbstractionReviewSetID 
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON MBR.MemberID = V.MemberID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON P.AbstractorID = A.AbstractorID
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON V.MeasureID = M.MeasureID
			INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK)
					ON V.MeasureComponentID = MC.MeasureComponentID
			LEFT OUTER JOIN dbo.Reviewer AS R WITH(NOLOCK)
					ON R.ReviewerID = V.ReviewerID
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
			((@MeasureComponentID IS NULL) OR (V.MeasureComponentID = @MeasureComponentID)) AND
			((@MeasureID IS NULL) OR (V.MeasureID = @MeasureID)) AND
			((@ReviewerID IS NULL) OR (V.ReviewerID = @ReviewerID) OR (@ReviewerID = -1 AND V.ReviewerID = NULL)) AND
			(
				(@UserName IS NULL) OR 
				(ISNULL(@FilterOnUserName, 0) = 0) OR 
				(A.UserName = @UserName) OR
				(R.UserName = @UserName)
			) AND
			((ISNULL(@ShowCompletedReviewsOnly, 0) = 0) OR (V.IsCompleted = 1) OR (V.IsCanceled = 1)) AND
			((@PursuitEventID IS NULL) OR (V.PursuitEventID = @PursuitEventID)) AND
			((@PursuitID IS NULL) OR (V.PursuitID = @PursuitID)) AND
			((@PursuitNumber IS NULL) OR (P.PursuitNumber LIKE @PursuitNumber)) AND
			((@IsComplete IS NULL) OR (ARST.IsCompleted = @IsComplete)) AND
			((@IsCritical IS NULL) OR (V.IsCritical = @IsCritical)) AND
			((@IsFixed IS NULL) OR (V.IsFixed = @IsFixed))
	ORDER BY MeasureAbbrev, AbstractorName
	OPTION	(OPTIMIZE FOR UNKNOWN);
		
END
GO
GRANT EXECUTE ON  [Report].[GetIRRReviewEntries] TO [Reporting]
GO
