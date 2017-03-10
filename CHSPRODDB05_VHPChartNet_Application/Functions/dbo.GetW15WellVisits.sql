SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetW15WellVisits]
(
	@MemberID int
)
RETURNS 
@Results table 
(
	RecordType varchar(20) NOT NULL,
	MemberID int NOT NULL,
	ProviderID int NOT NULL,
	ServiceDate datetime NOT NULL,
	MeasureID int NOT NULL,
	HlthHistoryFlag int NOT NULL,
	PhysHealthDevFlag int NOT NULL,
	MentalHlthDevFlag int NOT NULL,
	PhysExamFlag int NOT NULL,
	HlthEducFlag int NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	PRIMARY KEY CLUSTERED (RecordType, MemberID, ProviderID, ServiceDate)
)
AS
BEGIN;
	WITH W15DateRange AS
	(
		SELECT	MemberID, 
				DateOfBirth AS StartDate,
				DATEADD(dd, 90, DATEADD(yy, 1, DateOfBirth)) AS EndDate
		FROM	dbo.Member
		WHERE	MemberID = @MemberID
	)
	INSERT INTO @Results
	SELECT	DISTINCT
			'Administrative' AS RecordType,
			a.MemberID,
			0 AS ProviderID, --c.ProviderID,
			c.ServiceDate,
			a.MeasureID,
			HlthHistoryFlag = 1,
			PhysHealthDevFlag = 1,
			MentalHlthDevFlag = 1,
			PhysExamFlag = 1,
			HlthEducFlag = 1,
			d.StartDate,
			d.EndDate
	FROM    MemberMeasureSample a
			INNER JOIN Measure b ON a.MeasureID = b.MeasureID
			INNER JOIN AdministrativeEvent c ON a.MeasureID = c.MeasureID AND
												a.MemberID = c.MemberID
			INNER JOIN W15DateRange AS d ON a.MemberID = d.MemberID
	WHERE   HEDISMeasure = 'W15' AND
			c.Data_Source LIKE '%Well%' AND
			c.ServiceDate BETWEEN d.StartDate AND d.EndDate
	UNION
	SELECT  'Medical Record' AS RecordType,
			a.MemberID,
			0 AS ProviderID, --c.ProviderID,
			e.ServiceDate,
			a.MeasureID,
			HlthHistoryFlag = MAX(CASE WHEN e.HlthHistoryFlag = 1 THEN 1
								   ELSE 0
							  END),
			PhysHlthDevFlag = MAX(CASE WHEN e.PhysHlthDevFlag = 1 THEN 1
								   ELSE 0
							  END),
			MentalHlthDevFlag = MAX(CASE WHEN e.MentalHlthDevFlag = 1 THEN 1
									 ELSE 0
								END),
			PhysExamFlag = MAX(CASE WHEN e.PhysExamFlag = 1 THEN 1
								ELSE 0
						   END),
			HlthEducFlag = MAX(CASE WHEN e.HlthEducFlag = 1 THEN 1
								ELSE 0
						   END),
			f.StartDate,
			f.EndDate
	FROM    MemberMeasureSample a
			INNER JOIN Measure b ON a.MeasureID = b.MeasureID
			INNER JOIN Pursuit c ON a.MemberID = c.MemberID
			INNER JOIN PursuitEvent d ON c.PursuitID = d.PursuitID
			INNER JOIN MedicalRecordW15 e ON d.PursuitEventID = e.PursuitEventID
			INNER JOIN W15DateRange AS f ON a.Memberid = f.MemberID
	WHERE   HEDISMeasure = 'W15' AND
			e.ServiceDate BETWEEN f.StartDate AND f.EndDate
	GROUP BY a.MemberID,
			c.ProviderID,
			a.MeasureID,
			e.ServiceDate,
			f.StartDate,
			f.EndDate;

	UPDATE	t1
	SET		HlthHistoryFlag = CASE WHEN t2.HlthHistoryFlag = 1 THEN 0 ELSE t1.HlthHistoryFlag END,
			PhysHealthDevFlag = CASE WHEN t2.PhysHealthDevFlag = 1 THEN 0 ELSE t1.PhysHealthDevFlag END,
			MentalHlthDevFlag = CASE WHEN t2.MentalHlthDevFlag = 1 THEN 0 ELSE t1.MentalHlthDevFlag END,
			PhysExamFlag = CASE WHEN t2.PhysExamFlag = 1 THEN 0 ELSE t1.PhysExamFlag END,
			HlthEducFlag = CASE WHEN t2.HlthEducFlag = 1 THEN 0 ELSE t1.HlthEducFlag END
	FROM	@Results AS t1
			INNER JOIN @Results AS t2
					ON t2.MemberID = t1.MemberID AND
						t1.RecordType = 'Administrative' AND
						t2.RecordType = 'Medical Record' AND
						t2.ServiceDate BETWEEN DATEADD(dd, -14, t1.ServiceDate) AND DATEADD(dd, 14, t1.ServiceDate);
	
	RETURN 
END;
GO
