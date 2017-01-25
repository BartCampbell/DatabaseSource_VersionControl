SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetPDS]
(	
	@PursuitEventID int
)
RETURNS table 
AS
RETURN 
(
	WITH 
	DateTypeDescription(ID, Descr) AS
	(
		SELECT 'Admin EDD-Based', 'Delivery Date, Administrative Date'
		UNION
		SELECT 'Chart EDD-Based', 'Estimated Delivery Date, Medical Record'
		UNION
		SELECT 'Chart DOD-Based', 'Actual Delivery Date, Medical Record'
	),  
	ListBase AS
	(
		SELECT TOP 1
				R.PursuitID, 
				RV.PursuitEventID,
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				t.*,
				DDTPre.Descr AS PrenatalCareScoreDescr,
				DDTPost.Descr AS PostpartumCareScoreDescr
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Measure AS M
						ON M.MeasureID = RV.MeasureID AND
							M.HEDISMeasure = 'PDS'
				OUTER APPLY (SELECT TOP 1 * FROM dbo.GetPADateRanges(R.MemberID) AS tA WHERE tA.MeasureID = RV.MeasureID AND tA.EventDate = RV.EventDate) AS t
				LEFT OUTER JOIN DateTypeDescription AS DDTPre
						ON t.PrenatalCareScore = DDTPre.ID
				LEFT OUTER JOIN DateTypeDescription AS DDTPost
						ON t.PostpartumCareScore = DDTPost.ID
		WHERE	RV.MeasureID = t.MeasureID AND
				RV.EventDate = t.EventDate AND  
				RV.PursuitEventID = @PursuitEventID  
	),
	ListDateRangeBase(ListTypeID, ItemID, ItemDescr, StartDate, EndDate) AS
	(
		SELECT	1, 1, PrenatalCareScore, PrenatalCareStartDateScore, PrenatalCareEndDateScore
		FROM	ListBase 
		WHERE	PrenatalCareStartDateScore IS NOT NULL AND
				PrenatalCareEndDateScore IS NOT NULL
		UNION
		SELECT	1, 2, PrenatalCare1, PrenatalCareStartDate1, PrenatalCareEndDate1
		FROM	ListBase 
		WHERE	PrenatalCareStartDate1 IS NOT NULL AND
				PrenatalCareEndDate1 IS NOT NULL AND 
				AllowConcurrentScoringRanges = 1
		UNION 
		SELECT	1, 3, PrenatalCare2, PrenatalCareStartDate2, PrenatalCareEndDate2
		FROM	ListBase
		WHERE	PrenatalCareStartDate2 IS NOT NULL AND
				PrenatalCareEndDate2 IS NOT NULL  AND 
				AllowConcurrentScoringRanges = 1 
		UNION
		SELECT	1, 4, PrenatalCare3, PrenatalCareStartDate3, PrenatalCareEndDate3
		FROM	ListBase 
		WHERE	PrenatalCareStartDate3 IS NOT NULL AND
				PrenatalCareEndDate3 IS NOT NULL  AND 
				AllowConcurrentScoringRanges = 1 
		UNION
  		SELECT	2, 2, PostpartumCareScore, PostpartumCareStartDateScore, PostpartumCareEndDateScore
		FROM	ListBase 
		WHERE	PostpartumCareStartDateScore IS NOT NULL AND
				PostpartumCareEndDateScore IS NOT NULL 
		UNION      
		SELECT	2, 2, PostpartumCare1, PostpartumCareStartDate1, PostpartumCareEndDate1
		FROM	ListBase 
		WHERE	PostpartumCareStartDate1 IS NOT NULL AND
				PostpartumCareEndDate1 IS NOT NULL AND 
				AllowConcurrentScoringRangesPostpartum = 1  
		UNION
		SELECT	2, 3, PostpartumCare2, PostpartumCareStartDate2, PostpartumCareEndDate2
		FROM	ListBase
		WHERE	PostpartumCareStartDate2 IS NOT NULL AND
				PostpartumCareEndDate2 IS NOT NULL AND 
				AllowConcurrentScoringRangesPostpartum = 1 
	),
	ListDateRangeLinkBase(ListTypeID, ItemID, ItemID2, Tier) AS
	(
		SELECT	t1.ListTypeID, t1.ItemID, t2.ItemID, 1
		FROM	ListDateRangeBase AS t1
				INNER JOIN ListDateRangeBase AS t2
						ON t1.ListTypeID = t2.ListTypeID AND
							(
								t1.StartDate BETWEEN t2.StartDate AND t2.EndDate OR
								t1.EndDate BETWEEN t2.StartDate AND t2.EndDate OR
								t2.StartDate BETWEEN t1.StartDate AND t1.EndDate OR
								t2.EndDate BETWEEN t1.StartDate AND t1.EndDate                  
							) 
	),
	ListDateRangeLinks(ListTypeID, ItemID, ItemID2, Tier) AS
	(
		SELECT	ListTypeID,
				ItemID,
				ItemID2,
				Tier
		FROM	ListDateRangeLinkBase
		UNION ALL
		SELECT	t1.ListTypeID, t1.ItemID, t2.ItemID2, t1.Tier + 1
		FROM	ListDateRangeLinkBase AS t1
				INNER JOIN ListDateRangeLinks AS t2
						ON t1.ListTypeID = t2.ListTypeID AND
							t1.ItemID2 = t2.ItemID AND
							t1.ItemID <> t2.ItemID AND
							t1.ItemID2 <> t2.ItemID2  AND
							t1.Tier BETWEEN t2.Tier AND t2.Tier + 1 AND                 
							t1.Tier BETWEEN 1 AND 10        
	),
	ListDateRange AS
	(
		SELECT	t1.ListTypeID,
				t1.ItemID,
				MIN(t2.StartDate) AS StartDate,
				MAX(t2.EndDate) AS EndDate
		FROM	ListDateRangeLinks AS LDRL
				INNER JOIN ListDateRangeBase AS t1
						ON LDRL.ListTypeID = t1.ListTypeID AND 
							LDRL.ItemID = t1.ItemID 
				INNER JOIN ListDateRangeBase AS t2
						ON LDRL.ListTypeID = t2.ListTypeID AND 
							LDRL.ItemID2 = t2.ItemID   
		GROUP BY t1.ListTypeID, t1.ItemID
		HAVING	(t1.ItemID = MIN(t2.ItemID))               
	)
	SELECT	'Delivery Date' AS Title,
			dbo.ConvertDateToVarchar(t.AdminDeliveryDate) + ' (Administrative)' + COALESCE(', ' + dbo.ConvertDateToVarchar(t.MRDeliveryDate) + ' (Medical Record' + ISNULL(', ' + M.HEDISMeasure, '') + ')', '') AS [Value],
			1.0 AS SortOrder
	FROM	ListBase AS t
			LEFT OUTER JOIN dbo.Measure AS M
					ON M.MeasureID = t.DODSourceMeasureID
	UNION
  	SELECT	'Estimated Delivery Date' AS Title,
			dbo.ConvertDateToVarchar(MREstimatedDate) + ' (Medical Record' + ISNULL(', ' + M.HEDISMeasure, '') + ')' AS [Value],
			1.1 AS SortOrder
	FROM	ListBase AS t
			LEFT OUTER JOIN dbo.Measure AS M
					ON M.MeasureID = t.EDDSourceMeasureID
	WHERE	MREstimatedDate IS NOT NULL  
	--UNION
	--SELECT	'Last Enrollment Segment Start' AS Title,
	--		dbo.ConvertDateToVarchar(COALESCE(LB.LastEnrollSegStartDate, MMS.PPCLastEnrollSegStartDate, MMS.PPCPrenatalCareStartDate)) AS [Value],
	--		2.0 AS SortOrder
	--FROM	ListBase AS LB
	--		INNER JOIN dbo.MemberMeasureSample AS MMS
	--				ON LB.MemberMeasureSampleID = MMS.MemberMeasureSampleID
	--WHERE	LB.LastEnrollSegStartDate IS NOT NULL OR
	--		MMS.PPCLastEnrollSegStartDate IS NOT NULL OR
	--		MMS.PPCPrenatalCareStartDate IS NOT NULL  
	UNION
	SELECT	'Prenatal Reference' AS Title,
			PrenatalCareScoreDescr AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
	WHERE	AllowConcurrentScoringRanges = 0 AND
			PrenatalCareScoreDescr IS NOT NULL AND
			(MRDeliveryDate IS NOT NULL OR MREstimatedDate IS NOT NULL)          
	UNION
	SELECT	'Prenatal Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) AS [Value],
			3.1 + ((ROW_NUMBER() OVER (ORDER BY StartDate) - 1) * 0.1) AS SortOrder
	FROM	ListDateRange
	WHERE	ListTypeID = 1
	UNION
SELECT	'First-Two-Prenatal Date Range' AS Title,
			dbo.ConvertDateToVarchar(t.FirstTwoPrenatalStartDate) + 
				ISNULL(' (' + M1.HEDISMeasure + CASE WHEN t.FirstTwoPrenatalStartSourceHasMultiMeasures = 1 THEN '+' ELSE '' END + ')', '') + ' - ' + 
			dbo.ConvertDateToVarchar(t.FirstTwoPrenatalEndDate) +
				ISNULL(' (' + M2.HEDISMeasure + CASE WHEN t.FirstTwoPrenatalEndSourceHasMultiMeasures = 1 THEN '+' ELSE '' END + ')', '')AS [Value],
			4.0 AS SortOrder
	FROM	ListBase AS t
			LEFT OUTER JOIN dbo.Measure AS M1
					ON M1.MeasureID = t.FirstTwoPrenatalStartSourceMeasureID 
			LEFT OUTER JOIN dbo.Measure AS M2
					ON M2.MeasureID = t.FirstTwoPrenatalEndSourceMeasureID
	WHERE	t.FirstTwoPrenatalStartDate IS NOT NULL AND
			t.FirstTwoPrenatalEndDate IS NOT NULL
	UNION
  	SELECT	'Postpartum Reference' AS Title,
			PostpartumCareScoreDescr AS [Value],
			5.0 AS SortOrder
	FROM	ListBase
	WHERE	AllowConcurrentScoringRanges = 0 AND
			PostpartumCareScoreDescr IS NOT NULL AND
			MRDeliveryDate IS NOT NULL         
	UNION  
	SELECT	'Postpartum Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) AS [Value],
			5.1 + ((ROW_NUMBER() OVER (ORDER BY StartDate) - 1) * 0.1) AS SortOrder
	FROM	ListDateRange,
			ListBase
	WHERE	ListTypeID = 2
)
GO
