SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for IMA measures for this member.
--It uses administrative claims data from the AdministrativeEvent table.
--It uses Medical Record data from the MedicalRecordIMA table.
--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreIMA '561296'
--prRescoreMeasure 'ScoreIMA'
CREATE PROCEDURE [dbo].[ScoreIMA] @MemberID int
AS 
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent

	CREATE TABLE #HEDISSubMetricComponent
	(
	 HEDISSubMetricComponentID int IDENTITY(1, 1),
	 HEDISSubMetricComponentCode varchar(50),
	 HEDISSubMetricComponentDesc varchar(50),
	 HEDISSubMetricCode varchar(50)
	)

	INSERT  INTO #HEDISSubMetricComponent VALUES  
	('TDAP', 'Diphtheria, Tetanus, and Acellular pertussis', 'IMATD')
	,('DIPTH', 'Diphtheria', 'IMATD')
	,('TET', 'Tetanus', 'IMATD')
	,('AP', 'Acellular pertussis', 'IMATD')
	,('MEN', 'Meningococcal', 'IMAMEN')
	,('HPV', 'HPV', 'IMAHPV')



	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ProcCode_xref') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent_ProcCode_xref

	CREATE TABLE #HEDISSubMetricComponent_ProcCode_xref
	(
	 ProcCode varchar(10),
	 HEDISSubMetricComponentCode varchar(50)
	)

	INSERT  INTO #HEDISSubMetricComponent_ProcCode_xref VALUES  
	('90649', 'HPV')
	,('90650', 'HPV')
	,('90651', 'HPV')
	,('90644', 'Men')
	,('90734', 'Men')
	,('90715', 'Tdap')


	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ICD9Proc_xref') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent_ICD9Proc_xref

	CREATE TABLE #HEDISSubMetricComponent_ICD9Proc_xref
	(
	 ICD9Proc varchar(10),
	 HEDISSubMetricComponentCode varchar(50)
	)

	--INSERT  INTO #HEDISSubMetricComponent_ICD9Proc_xref
	--VALUES  ('99.39', 'TDAP')
	--INSERT  INTO #HEDISSubMetricComponent_ICD9Proc_xref
	--VALUES  ('99.36', 'DIPTH')
	--INSERT  INTO #HEDISSubMetricComponent_ICD9Proc_xref
	--VALUES  ('99.38', 'TET')

	IF OBJECT_ID('tempdb..#AdministrativeEvent') IS NOT NULL 
		DROP TABLE #AdministrativeEvent

	SELECT DISTINCT
			MeasureID = a.MeasureID,
			HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode,
			HEDISSubMetricComponentID = c.HEDISSubMetricComponentID,
			HEDISSubMetricCode = c.HEDISSubMetricCode,
			MemberID = a.MemberID ,
			ServiceDate = a.ServiceDate,
			DateOfBirth,
			DateOfBirth_10years = DATEADD(yy, 10, DateOfBirth),
			DateOfBirth_11years = DATEADD(yy, 11, DateOfBirth),
			DateOfBirth_13years = DATEADD(yy, 13, DateOfBirth)
	INTO    #AdministrativeEvent
	FROM    AdministrativeEvent a
			INNER JOIN #HEDISSubMetricComponent_ProcCode_xref b ON a.ProcedureCode = b.ProcCode
			INNER JOIN #HEDISSubMetricComponent c ON b.HEDISSubMetricComponentCode = c.HEDISSubMetricComponentCode
			INNER JOIN Member d ON a.MemberID = d.MemberID
	WHERE   a.MemberID = @MemberID 

	--set up a rules table that is 1 row per HEDISSubMetric, containing 
	--all necessary decision flags:

	IF OBJECT_ID('tempdb..#single_shot_xref') IS NOT NULL 
		DROP TABLE #single_shot_xref

	CREATE TABLE #single_shot_xref
	(
	 compound_shot varchar(50),
	 single_shot varchar(50),
	 HEDISSubMetricCode varchar(50),
	 HEDISSubMetricComponentCode varchar(50),
	 HEDISSubMetricID int,
	 HEDISSubMetricComponentID int
	)

	INSERT  INTO #single_shot_xref
			(compound_shot,
			 single_shot,
			 HEDISSubMetricCode,
			 HEDISSubMetricComponentCode
			)
			SELECT  'Diphtheria',
					'Diphtheria',
					'IMATD',
					'DIPTH'
			UNION ALL --standard
			SELECT  'Tetanus',
					'Tetanus',
					'IMATD',
					'TET'
			UNION ALL --standard
			SELECT  'Acellular pertussis',
					'Acellular pertussis',
					'IMATD',
					'AP'
			UNION ALL --standard
			SELECT  'Td',
					'Diphtheria',
					'IMATD',
					'DIPTH'
			UNION ALL
			SELECT  'Td',
					'Tetanus',
					'IMATD',
					'TET'
			UNION ALL
			SELECT  'Tdap',
					'Tdap',
					'IMATD',
					'TDAP'
			UNION ALL --standard
			SELECT  'Meningococcal',
					'Meningococcal',
					'IMAMEN',
					'MEN'	
			UNION ALL --standard
			SELECT  'HPV',
					'HPV',
					'IMAHPV',
					'HPV'	
	--INSERT INTO #single_shot_xref('HPV','IMAHPV','HPV','IMA',27,1029,6)
	UPDATE  #single_shot_xref
	SET     HEDISSubMetricComponentID = b.HEDISSubMetricComponentID
	FROM    #single_shot_xref a
			INNER JOIN #HEDISSubMetricComponent b ON a.HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode


	UPDATE  #single_shot_xref
	SET     HEDISSubMetricID = b.HEDISSubMetricID
	FROM    #single_shot_xref a
			INNER JOIN HEDISSubMetric b ON a.HEDISSubMetricCode = b.HEDISSubMetricCode

	IF OBJECT_ID('tempdb..#MedicalRecordEvent') IS NOT NULL 
		DROP TABLE #MedicalRecordEvent

	SELECT  a.*,
			b.MemberID,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			DateOfBirth,
			DateOfBirth_10years = DATEADD(yy, 10, DateOfBirth),
			DateOfBirth_11years = DATEADD(yy, 11, DateOfBirth),
			DateOfBirth_13years = DATEADD(yy, 13, DateOfBirth)
	INTO    #MedicalRecordEvent
	FROM    MedicalRecordIMA a
			INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
			INNER JOIN DropDownValues_IMAEvidence e ON a.IMAEvidenceID = e.IMAEvidenceID
			INNER JOIN dbo.DropDownValues_IMAEvent f ON f.IMAEventID = e.IMAEventID AND f.DisplayText NOT LIKE '%Parent/Guardian Refusal%'
			INNER JOIN #single_shot_xref c ON e.DisplayText = c.compound_shot
			INNER JOIN Member d ON b.MemberID = d.MemberID
	WHERE   b.MemberID = @MemberID AND
			NOT EXISTS ( SELECT *
						 FROM   #AdministrativeEvent a2
						 WHERE  b.MemberID = a2.MemberID AND
								c.HEDISSubMetricComponentID = a2.HEDISSubMetricComponentID AND
								a.ServiceDate BETWEEN DATEADD(dd, -14, a2.ServiceDate) AND DATEADD(dd, 14, a2.ServiceDate) )

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecordDetail') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentMetricsMedicalRecordDetail


	SELECT  MemberID,
			ServiceDate,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			--************************************************************************************************
			dtap_svc_adm = 0,
			diptheria_svc_adm = 0,
			tetanus_svc_adm = 0,
			total_dtap_adm = 0,
			dtap_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'TDAP' AND
									ServiceDate BETWEEN DateOfBirth_10years
												AND     DateOfBirth_13years THEN 1
							   ELSE 0
						  END,
			diptheria_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'DIPTH' AND
										 ServiceDate BETWEEN DateOfBirth_10years
													 AND     DateOfBirth_13years
									THEN 1
									ELSE 0
							   END,
			tetanus_svc_mr = CASE WHEN HEDISSubMetricComponentCode = 'TET' AND
									   ServiceDate BETWEEN DateOfBirth_10years
												   AND     DateOfBirth_13years
								  THEN 1
								  ELSE 0
							 END,
			total_dtap_mr = 0,
			dtap_svc_hyb = 0,
			diptheria_svc_hyb = 0,
			tetanus_svc_hyb = 0,
			total_dtap_hyb = 0,
			--************************************************************************************************
			men_count_adm = 0,
			men_count_mr = CASE WHEN HEDISSubMetricComponentCode = 'MEN' AND
									 ServiceDate BETWEEN DateOfBirth_11years
												 AND     DateOfBirth_13years
								THEN 1
								ELSE 0
						   END,
			men_count_hyb = 0
			--************************************************************************************************
	INTO    #SubMetricRuleComponentMetricsMedicalRecordDetail
	FROM    #MedicalRecordEvent a
	UNION ALL
	SELECT  MemberID,
			ServiceDate,
			HEDISSubMetricCode,
			HEDISSubMetricComponentCode,
			--************************************************************************************************
			dtap_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'TDAP' AND
									 ServiceDate BETWEEN DateOfBirth_10years
												 AND     DateOfBirth_13years
								THEN 1
								ELSE 0
						   END,
			diptheria_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'DIPTH' AND
										  ServiceDate BETWEEN DateOfBirth_10years
													  AND     DateOfBirth_13years
									 THEN 1
									 ELSE 0
								END,
			tetanus_svc_adm = CASE WHEN HEDISSubMetricComponentCode = 'TET' AND
										ServiceDate BETWEEN DateOfBirth_10years
													AND     DateOfBirth_13years
								   THEN 1
								   ELSE 0
							  END,
			total_dtap_adm = 0,
			dtap_svc_mr = 0,
			diptheria_svc_mr = 0,
			tetanus_svc_mr = 0,
			total_dtap_mr = 0,
			dtap_svc_hyb = 0,
			diptheria_svc_hyb = 0,
			tetanus_svc_hyb = 0,
			total_dtap_hyb = 0,
			--************************************************************************************************
			men_count_adm = CASE WHEN HEDISSubMetricComponentCode = 'MEN' AND
									  ServiceDate BETWEEN DateOfBirth_11years
												  AND     DateOfBirth_13years
								 THEN 1
								 ELSE 0
							END,
			men_count_mr = 0,
			men_count_hyb = 0
			--************************************************************************************************
	FROM    #AdministrativeEvent a

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord;
		WITH    Results
				  AS (
					  SELECT    MemberID,
								ServiceDate,
								HEDISSubMetricCode,
								--************************************************************************************************
								dtap_svc_adm = MAX(dtap_svc_adm),
								diptheria_svc_adm = MAX(diptheria_svc_adm),
								tetanus_svc_adm = MAX(tetanus_svc_adm),
								total_dtap_adm = 0,
								dtap_svc_mr = MAX(dtap_svc_mr),
								diptheria_svc_mr = MAX(diptheria_svc_mr),
								tetanus_svc_mr = MAX(tetanus_svc_mr),
								total_dtap_mr = 0,
								dtap_svc_hyb = MAX(dtap_svc_adm + dtap_svc_mr),
								diptheria_svc_hyb = MAX(diptheria_svc_adm +
														diptheria_svc_mr),
								tetanus_svc_hyb = MAX(tetanus_svc_adm +
													  tetanus_svc_mr),
								total_dtap_hyb = 0,
								--************************************************************************************************
								men_count_adm = MAX(men_count_adm),
								men_count_mr = MAX(men_count_mr),
								men_count_hyb = MAX(CASE WHEN men_count_adm > 0
														 THEN men_count_adm
														 ELSE men_count_mr
													END)
								--************************************************************************************************
					  FROM      #SubMetricRuleComponentMetricsMedicalRecordDetail
					  GROUP BY  MemberID,
								ServiceDate,
								HEDISSubMetricCode
					 )
		SELECT  MemberID,
				HEDISSubMetricCode,
				dtap_svc_adm = SUM(dtap_svc_adm),
				diptheria_svc_adm = SUM(diptheria_svc_adm),
				tetanus_svc_adm = SUM(tetanus_svc_adm),
				total_dtap_adm = SUM(total_dtap_adm),
				dtap_svc_mr = SUM(dtap_svc_mr),
				diptheria_svc_mr = SUM(diptheria_svc_mr),
				tetanus_svc_mr = SUM(tetanus_svc_mr),
				total_dtap_mr = SUM(total_dtap_mr),
				dtap_svc_hyb = SUM(dtap_svc_hyb),
				diptheria_svc_hyb = SUM(diptheria_svc_hyb),
				tetanus_svc_hyb = SUM(tetanus_svc_hyb),
				total_dtap_hyb = SUM(total_dtap_hyb),
				--************************************************************************************************
				men_count_adm = SUM(men_count_adm),
				men_count_mr = SUM(men_count_mr),
				men_count_hyb = SUM(men_count_hyb)
		INTO    #SubMetricRuleComponentMetricsMedicalRecord
		FROM    Results
		GROUP BY MemberID,
				HEDISSubMetricCode;

	UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
	SET     total_dtap_adm = 1
	WHERE   dtap_svc_adm > 0 OR
			(diptheria_svc_adm > 0 AND
			 tetanus_svc_adm > 0
			) 

	UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
	SET     total_dtap_mr = 1
	WHERE   dtap_svc_mr > 0 OR
			(diptheria_svc_mr > 0 AND
			 tetanus_svc_mr > 0
			) 

	UPDATE  #SubMetricRuleComponentMetricsMedicalRecord
	SET     total_dtap_hyb = 1
	WHERE   dtap_svc_hyb > 0 OR
			(diptheria_svc_hyb > 0 AND
			 tetanus_svc_hyb > 0
			)

	IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponents

	SELECT  MemberMeasureMetricScoringID,
			c.HEDISSubMetricCode,
			--****************************************************************************************
			dtap_events_admin = SUM(total_dtap_adm),
			dtap_events_mr_supp = SUM(total_dtap_mr),
			dtap_events_hyb = SUM(total_dtap_hyb),
			--****************************************************************************************
			men_events_admin = SUM(men_count_adm),
			men_events_mr_supp = SUM(men_count_mr),
			men_events_hyb = SUM(men_count_hyb),
			--****************************************************************************************
			combo1_admin = 0,
			combo1_mr = 0,
			combo1_hyb = 0
			--************************************************************************************************
	INTO    #SubMetricRuleComponents
	FROM    MemberMeasureMetricScoring a
			INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
			INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
			LEFT JOIN #SubMetricRuleComponentMetricsMedicalRecord d ON d.MemberID = b.MemberID AND
																  d.HEDISSubMetricCode = c.HEDISSubMetricCode
	WHERE   HEDISMeasureInit = 'IMA' AND
			b.MemberID = @MemberID
	GROUP BY MemberMeasureMetricScoringID,
			c.HEDISSubMetricCode

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentsTotal') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentsTotal

	SELECT  dtap_events_admin = SUM(ISNULL(dtap_events_admin, 0)),
			dtap_events_mr_supp = SUM(ISNULL(dtap_events_mr_supp, 0)),
			dtap_events_hyb = SUM(ISNULL(dtap_events_hyb, 0)),
			men_events_admin = SUM(ISNULL(men_events_admin, 0)),
			men_events_mr_supp = SUM(ISNULL(men_events_mr_supp, 0)),
			men_events_hyb = SUM(ISNULL(men_events_hyb, 0)),
			combo1_admin = SUM(ISNULL(combo1_admin, 0)),
			combo1_mr = SUM(ISNULL(combo1_mr, 0)),
			combo1_hyb = SUM(ISNULL(combo1_hyb, 0))
	INTO    #SubMetricRuleComponentsTotal
	FROM    #SubMetricRuleComponents
	WHERE   HEDISSubMetricCode NOT IN ('IMACMB1')


	UPDATE  #SubMetricRuleComponents
	SET     combo1_admin = CASE WHEN b.dtap_events_admin >= 1 AND
									 b.men_events_admin >= 1 THEN 1
								ELSE 0
						   END,
			combo1_mr = CASE WHEN b.dtap_events_mr_supp >= 1 AND
								  b.men_events_mr_supp >= 1 THEN 1
							 ELSE 0
						END,
			combo1_hyb = CASE WHEN b.dtap_events_hyb >= 1 AND
								   b.men_events_hyb >= 1 THEN 1
							  ELSE 0
						 END
	FROM    #SubMetricRuleComponents a
			CROSS JOIN #SubMetricRuleComponentsTotal b
	WHERE   HEDISSubMetricCode = 'IMACMB1'


	--Evaluate Exclusion(s)...
	IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
		DROP TABLE #Exclusions

	SELECT  MemberMeasureMetricScoringID,
			ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
									   FROM     dbo.MedicalRecordIMA a2
												INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
												INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
												INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
												INNER JOIN dbo.DropDownValues_IMAEvidence AS v2 ON a2.IMAEvidenceID = v2.IMAEvidenceID
												INNER JOIN dbo.DropDownValues_IMAEvent AS e2 ON v2.IMAEventID = e2.IMAEventID
									   WHERE    b2.MemberID = b.MemberID AND
												e2.DisplayText = 'Exclusion' AND  
												a2.ServiceDate BETWEEN d2.DateOfBirth 
															   AND
																  DATEADD(yy, 13, d2.DateOfBirth)
									  ) > 0 THEN 1
								 ELSE 0
							END,
			ExclusionReason = CONVERT(varchar(200),	(SELECT   MIN(v2.DisplayText)
													   FROM     dbo.MedicalRecordIMA a2
																INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
																INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
																INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
																INNER JOIN dbo.DropDownValues_IMAEvidence AS v2 ON a2.IMAEvidenceID = v2.IMAEvidenceID
																INNER JOIN dbo.DropDownValues_IMAEvent AS e2 ON v2.IMAEventID = e2.IMAEventID
													   WHERE    b2.MemberID = b.MemberID AND
																e2.DisplayText = 'Exclusion' AND  
																a2.ServiceDate BETWEEN d2.DateOfBirth 
																			   AND
																				  DATEADD(yy, 13, d2.DateOfBirth)))
	INTO    #Exclusions
	FROM    MemberMeasureMetricScoring a
			INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
			INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
	WHERE   HEDISMeasureInit = 'IMA' AND
			MemberID = @MemberID;
		
	--Calculation of Hit Rules and Application to Scoring Table:

	UPDATE  MemberMeasureMetricScoring
	SET     --select  
			MedicalRecordHitCount = CASE WHEN dtap_events_mr_supp >= 1 THEN 1
										 WHEN men_events_mr_supp >= 1 THEN 1
										 WHEN combo1_mr >= 1 THEN 1
										 ELSE 0
									END,
			HybridHitCount = CASE WHEN AdministrativeHitCount >= 1 THEN 1
								  WHEN dtap_events_hyb >= 1 THEN 1
								  WHEN men_events_hyb >= 1 THEN 1
								  WHEN combo1_hyb >= 1 THEN 1
								  ELSE 0
							 END,
			ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
								  ELSE 0
							 END,
			ExclusionReason = x.ExclusionReason
	FROM    MemberMeasureMetricScoring a
			INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
			INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
			LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
	WHERE b.MemberID=@MemberID



	----**********************************************************************************************
	----**********************************************************************************************
	----temp table cleanup
	----**********************************************************************************************
	----**********************************************************************************************

	/*
	--XXXXXXXXXXXXXXXXXXXXXXXXXXX
	SELECT * FROM #HEDISSubMetricComponent
	SELECT * FROM #single_shot_xref
	SELECT * FROM #MedicalRecordEvent
	SELECT * FROM #SubMetricRuleComponentMetricsMedicalRecordDetail
	SELECT * FROM #SubMetricRuleComponentMetricsMedicalRecord
	SELECT * FROM #SubMetricRuleComponents
	SELECT * FROM #SubMetricRuleComponentsTotal
	*/
	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent

	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ProcCode_xref') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent_ProcCode_xref

	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_DiagCode3_xref') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent_DiagCode3_xref

	IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ICD9Proc_xref') IS NOT NULL 
		DROP TABLE #HEDISSubMetricComponent_ICD9Proc_xref

	IF OBJECT_ID('tempdb..#AdministrativeEvent') IS NOT NULL 
		DROP TABLE #AdministrativeEvent

	IF OBJECT_ID('tempdb..#single_shot_xref') IS NOT NULL 
		DROP TABLE #single_shot_xref

	IF OBJECT_ID('tempdb..#MedicalRecordEvent') IS NOT NULL 
		DROP TABLE #MedicalRecordEvent

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecordDetail') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentMetricsMedicalRecordDetail

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord

	IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponents

	IF OBJECT_ID('tempdb..#SubMetricRuleComponentsTotal') IS NOT NULL 
		DROP TABLE #SubMetricRuleComponentsTotal

	--Update HPV Metric and Combination 2
	DECLARE @Date1 AS Date
	DECLARE @Date2 AS Date
	DECLARE @DOB AS Date
	SELECT @DOB=DateOfBirth FROM Member WHERE MemberID=@MemberID
	DECLARE @MemberMeasureSampleID AS INT
	SELECT TOP 1 @MemberMeasureSampleID = MemberMeasureSampleID FROM MemberMeasureSample WHERE MemberID=@MemberID AND MeasureID=27
	
	DECLARE @HEDISSubMetricID_IMAHPV AS INT
	SELECT @HEDISSubMetricID_IMAHPV=HEDISSubMetricID FROM HEDISSubMetric WHERE MeasureID=27 AND HEDISSubMetricCode='IMAHPV'
	DECLARE @HEDISSubMetricID_IMATdap AS INT
	SELECT @HEDISSubMetricID_IMATdap=HEDISSubMetricID FROM HEDISSubMetric WHERE MeasureID=27 AND HEDISSubMetricCode='IMATD'
	DECLARE @HEDISSubMetricID_IMACMB1 AS INT
	SELECT @HEDISSubMetricID_IMACMB1=HEDISSubMetricID FROM HEDISSubMetric WHERE MeasureID=27 AND HEDISSubMetricCode='IMACMB1'
	DECLARE @HEDISSubMetricID_IMACMB2 AS INT
	SELECT @HEDISSubMetricID_IMACMB2=HEDISSubMetricID FROM HEDISSubMetric WHERE MeasureID=27 AND HEDISSubMetricCode='IMACMB2'
	DECLARE @HEDISSubMetricID_IMAMEN AS INT
	SELECT @HEDISSubMetricID_IMAMEN=HEDISSubMetricID FROM HEDISSubMetric WHERE MeasureID=27 AND HEDISSubMetricCode='IMAMEN'

	--Meningococcal
	SELECT @Date1 = DateAdd(Year,11,@DOB),@Date2 = DateAdd(Year,13,@DOB)
	IF EXISTS (SELECT MedicalRecordKey 
			FROM MedicalRecordIMA D INNER JOIN PursuitEvent PE ON PE.PursuitID = D.PursuitID 
				INNER JOIN DropDownValues_IMAEvidence IE ON D.IMAEvidenceID = IE.IMAEvidenceID AND IMAEventID<>3
			WHERE PE.MemberMeasureSampleID = @MemberMeasureSampleID AND PE.MeasureID=27 AND D.IMAEvidenceID IN (1, 9)
				AND D.ServiceDate>=@Date1 AND D.ServiceDate<=@Date2
			UNION
			SELECT DISTINCT ServiceDate FROM AdministrativeEvent 
				WHERE HEDISSubMetricID = @HEDISSubMetricID_IMAMEN AND MemberID=@MemberID
				 AND ServiceDate>=@Date1 AND ServiceDate<=@Date2
		)
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=1,MedicalRecordHitCount=1,HybridHit=1,HybridHitCount=1
			WHERE HEDISSubMetricID = @HEDISSubMetricID_IMAMEN AND MemberMeasureSampleID = @MemberMeasureSampleID
	END
	ELSE
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=0,MedicalRecordHitCount=0,HybridHit=0,HybridHitCount=0
			WHERE HEDISSubMetricID = @HEDISSubMetricID_IMAMEN AND MemberMeasureSampleID = @MemberMeasureSampleID
	END

	--Tdap
	SELECT @Date1 = DateAdd(Year,10,@DOB),@Date2 = DateAdd(Year,13,@DOB)
	IF EXISTS (SELECT DISTINCT D.ServiceDate 
			FROM MedicalRecordIMA D INNER JOIN PursuitEvent PE ON PE.PursuitID = D.PursuitID 
				INNER JOIN DropDownValues_IMAEvidence IE ON D.IMAEvidenceID = IE.IMAEvidenceID AND IMAEventID<>3
			WHERE PE.MemberMeasureSampleID = @MemberMeasureSampleID AND PE.MeasureID=27 AND D.IMAEvidenceID IN (2, 3, 4, 6, 7, 10, 11, 12, 13)
				AND D.ServiceDate>=@Date1 AND D.ServiceDate<=@Date2
			UNION
			SELECT DISTINCT ServiceDate FROM AdministrativeEvent 
				WHERE HEDISSubMetricID = @HEDISSubMetricID_IMATdap AND MemberID=@MemberID
				 AND ServiceDate>=@Date1 AND ServiceDate<=@Date2
		)
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=1,MedicalRecordHitCount=1,HybridHit=1,HybridHitCount=1
			WHERE HEDISSubMetricID = @HEDISSubMetricID_IMATdap AND MemberMeasureSampleID = @MemberMeasureSampleID

		IF EXISTS(SELECT * FROM MemberMeasureMetricScoring WHERE MedicalRecordHit=1 AND HEDISSubMetricID = @HEDISSubMetricID_IMAMEN AND MemberMeasureSampleID = @MemberMeasureSampleID)
			Update MemberMeasureMetricScoring SET MedicalRecordHit=1,MedicalRecordHitCount=1,HybridHit=1,HybridHitCount=1
				WHERE HEDISSubMetricID = @HEDISSubMetricID_IMACMB1 AND MemberMeasureSampleID = @MemberMeasureSampleID	
	END
	ELSE
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=0,MedicalRecordHitCount=0,HybridHit=0,HybridHitCount=0
			WHERE HEDISSubMetricID IN (@HEDISSubMetricID_IMATdap,@HEDISSubMetricID_IMACMB1) AND MemberMeasureSampleID = @MemberMeasureSampleID	
	END

	--HPV
	SELECT @Date1 = DateAdd(Year,9,@DOB),@Date2 = DateAdd(Year,13,@DOB)
	IF (SELECT COUNT(*) FROM (
			SELECT DISTINCT D.ServiceDate
				FROM MedicalRecordIMA D INNER JOIN PursuitEvent PE ON PE.PursuitID = D.PursuitID 
					INNER JOIN DropDownValues_IMAEvidence IE ON D.IMAEvidenceID = IE.IMAEvidenceID AND IMAEventID<>3
				WHERE PE.MemberMeasureSampleID = @MemberMeasureSampleID AND PE.MeasureID=27 AND D.IMAEvidenceID IN (14,15)
					AND D.ServiceDate>=@Date1 AND D.ServiceDate<=@Date2
			UNION
			SELECT DISTINCT ServiceDate FROM AdministrativeEvent 
				WHERE HEDISSubMetricID = @HEDISSubMetricID_IMAHPV AND MemberID=@MemberID
				 AND ServiceDate>=@Date1 AND ServiceDate<=@Date2
		) T
		)>=3
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=1,MedicalRecordHitCount=1,HybridHit=1,HybridHitCount=1
			WHERE HEDISSubMetricID = @HEDISSubMetricID_IMAHPV AND MemberMeasureSampleID = @MemberMeasureSampleID

		IF EXISTS(SELECT * FROM MemberMeasureMetricScoring WHERE MedicalRecordHit=1 AND HEDISSubMetricID = @HEDISSubMetricID_IMAMEN AND MemberMeasureSampleID = @MemberMeasureSampleID)
			AND
			EXISTS(SELECT * FROM MemberMeasureMetricScoring WHERE MedicalRecordHit=1 AND HEDISSubMetricID = @HEDISSubMetricID_IMATdap AND MemberMeasureSampleID = @MemberMeasureSampleID)

			Update MemberMeasureMetricScoring SET MedicalRecordHit=1,MedicalRecordHitCount=1,HybridHit=1,HybridHitCount=1
				WHERE HEDISSubMetricID = @HEDISSubMetricID_IMACMB2 AND MemberMeasureSampleID = @MemberMeasureSampleID			
	END
	ELSE
	BEGIN
		Update MemberMeasureMetricScoring SET MedicalRecordHit=0,MedicalRecordHitCount=0,HybridHit=0,HybridHitCount=0
			WHERE HEDISSubMetricID IN (@HEDISSubMetricID_IMAHPV,@HEDISSubMetricID_IMACMB2) AND MemberMeasureSampleID = @MemberMeasureSampleID	
	END

		EXEC dbo.RunPostScoringSteps @HedisMeasure = 'IMA', @MemberID = @MemberID;
GO
