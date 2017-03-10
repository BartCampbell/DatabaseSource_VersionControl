SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetPPC]
(	
	@PursuitEventID int
)
RETURNS TABLE 
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
				DDTPre.Descr AS PPCPrenatalCareScoreDescr,
				DDTPost.Descr AS PPCPostpartumCareScoreDescr
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				OUTER APPLY (SELECT TOP 1 * FROM dbo.GetPPCDateRanges(R.MemberID) AS tA WHERE tA.MeasureID = RV.MeasureID AND tA.EventDate = RV.EventDate) AS t
				LEFT OUTER JOIN DateTypeDescription AS DDTPre
						ON t.PPCPrenatalCareScore = DDTPre.ID
				LEFT OUTER JOIN DateTypeDescription AS DDTPost
						ON t.PPCPostpartumCareScore = DDTPost.ID
		WHERE	RV.MeasureID = t.MeasureID AND
				RV.EventDate = t.EventDate AND  
				RV.PursuitEventID = @PursuitEventID  
	),
	ListDateRangeBase(ListTypeID, ItemID, ItemDescr, StartDate, EndDate) AS
	(
		SELECT	1, 1, PPCPrenatalCareScore, PPCPrenatalCareStartDateScore, PPCPrenatalCareEndDateScore
		FROM	ListBase 
		WHERE	PPCPrenatalCareStartDateScore IS NOT NULL AND
				PPCPrenatalCareEndDateScore IS NOT NULL
		UNION
		SELECT	1, 2, PPCPrenatalCare1, PPCPrenatalCareStartDate1, PPCPrenatalCareEndDate1
		FROM	ListBase 
		WHERE	PPCPrenatalCareStartDate1 IS NOT NULL AND
				PPCPrenatalCareEndDate1 IS NOT NULL AND 
				AllowConcurrentScoringRanges = 1
		UNION 
		SELECT	1, 3, PPCPrenatalCare2, PPCPrenatalCareStartDate2, PPCPrenatalCareEndDate2
		FROM	ListBase
		WHERE	PPCPrenatalCareStartDate2 IS NOT NULL AND
				PPCPrenatalCareEndDate2 IS NOT NULL  AND 
				AllowConcurrentScoringRanges = 1 
		UNION
		SELECT	1, 4, PPCPrenatalCare3, PPCPrenatalCareStartDate3, PPCPrenatalCareEndDate3
		FROM	ListBase 
		WHERE	PPCPrenatalCareStartDate3 IS NOT NULL AND
				PPCPrenatalCareEndDate3 IS NOT NULL  AND 
				AllowConcurrentScoringRanges = 1 
		UNION
  		SELECT	2, 2, PPCPostpartumCareScore, PPCPostpartumCareStartDateScore, PPCPostpartumCareEndDateScore
		FROM	ListBase 
		WHERE	PPCPostpartumCareStartDateScore IS NOT NULL AND
				PPCPostpartumCareEndDateScore IS NOT NULL 
		UNION      
		SELECT	2, 2, PPCPostpartumCare1, PPCPostpartumCareStartDate1, PPCPostpartumCareEndDate1
		FROM	ListBase 
		WHERE	PPCPostpartumCareStartDate1 IS NOT NULL AND
				PPCPostpartumCareEndDate1 IS NOT NULL AND 
				AllowConcurrentScoringRangesPostpartum = 1  
		UNION
		SELECT	2, 3, PPCPostpartumCare2, PPCPostpartumCareStartDate2, PPCPostpartumCareEndDate2
		FROM	ListBase
		WHERE	PPCPostpartumCareStartDate2 IS NOT NULL AND
				PPCPostpartumCareEndDate2 IS NOT NULL AND 
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
			dbo.ConvertDateToVarchar(AdminDeliveryDate) + ' (Administrative)' + COALESCE(', ' + dbo.ConvertDateToVarchar(MRDeliveryDate) + ' (Medical Record)', '') AS [Value],
			1.0 AS SortOrder
	FROM	ListBase
	UNION
  	SELECT	'Estimated Delivery Date' AS Title,
			dbo.ConvertDateToVarchar(MREstimatedDate) + ' (Medical Record)' AS [Value],
			1.1 AS SortOrder
	FROM	ListBase
	WHERE	MREstimatedDate IS NOT NULL  
	UNION
	SELECT	'Last Enrollment Segment Start' AS Title,
			dbo.ConvertDateToVarchar(COALESCE(LB.LastEnrollSegStartDate, MMS.PPCLastEnrollSegStartDate, MMS.PPCPrenatalCareStartDate)) AS [Value],
			2.0 AS SortOrder
	FROM	ListBase AS LB
			INNER JOIN dbo.MemberMeasureSample AS MMS
					ON LB.MemberMeasureSampleID = MMS.MemberMeasureSampleID
	WHERE	LB.LastEnrollSegStartDate IS NOT NULL OR
			MMS.PPCLastEnrollSegStartDate IS NOT NULL OR
			MMS.PPCPrenatalCareStartDate IS NOT NULL  
	UNION
	SELECT	'Enrollment Category' AS Title,
			PC.PPCEnrollmentCategory AS [Value],
			2.1 AS SortOrder
	FROM	ListBase AS LB
			LEFT OUTER JOIN dbo.PPCEnrollmentCategory AS PC
					ON LB.CalcAdminEnrollmentCategoryID = PC.PPCEnrollmentCategoryID
	UNION
	SELECT	'Prenatal Reference' AS Title,
			PPCPrenatalCareScoreDescr AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
	WHERE	AllowConcurrentScoringRanges = 0 AND
			PPCPrenatalCareScoreDescr IS NOT NULL AND
			(MRDeliveryDate IS NOT NULL OR MREstimatedDate IS NOT NULL)          
	UNION
	SELECT	'Prenatal Qualifying Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) AS [Value],
			3.1 + ((ROW_NUMBER() OVER (ORDER BY StartDate) - 1) * 0.1) AS SortOrder
	FROM	ListDateRange
	WHERE	ListTypeID = 1
	UNION
  	SELECT	'Postpartum Reference' AS Title,
			PPCPostpartumCareScoreDescr AS [Value],
			4.0 AS SortOrder
	FROM	ListBase
	WHERE	AllowConcurrentScoringRanges = 0 AND
			PPCPostpartumCareScoreDescr IS NOT NULL AND
			MRDeliveryDate IS NOT NULL         
	UNION  
	SELECT	'Postpartum Qualifying Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) AS [Value],
			4.1 + ((ROW_NUMBER() OVER (ORDER BY StartDate) - 1) * 0.1) AS SortOrder
	FROM	ListDateRange,
			ListBase
	WHERE	ListTypeID = 2
)

GO
