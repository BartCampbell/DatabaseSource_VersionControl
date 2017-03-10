SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/5/2012
-- Description:	Refreshes event-level data from ChartNet.
-- =============================================
CREATE PROCEDURE [ChartNet].[RefreshEvents]
(
	@DataRunID int,
	@FlexDaysforFPCPPC tinyint = 30,
	@FlexDaysForMRP tinyint = 7
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;

	SELECT	@DataSetID = DR.DataSetID, 
			@MeasureSetID = DR.MeasureSetID,
			@OwnerID = DS.OwnerID
	FROM	Batch.DataRuns AS DR
			INNER JOIN Batch.DataSets AS DS
					ON DR.DataSetID = DS.DataSetID
	WHERE	(DR.DataRunID = @DataRunID);

	DECLARE @CloseTag varchar(16);	
	DECLARE @OpenTag varchar(16);

	SET @CloseTag = '</ b>';
	SET @OpenTag = '<b>';

	DECLARE @Trimmer varchar(36);
	SET @Trimmer = REPLACE(CONVERT(varchar(36), NEWID()), '-', '');

	IF OBJECT_ID('tempdb..#ServiceInfo') IS NOT NULL
		DROP TABLE #ServiceInfo;

	SELECT	PursuitNumber,
			RowID,
			ServiceDate,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo01)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue01, '')))) + @CloseTag AS ServiceHtml01,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo02)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue02, '')))) + @CloseTag AS ServiceHtml02,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo03)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue03, '')))) + @CloseTag AS ServiceHtml03,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo04)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue04, '')))) + @CloseTag AS ServiceHtml04,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo05)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue05, '')))) + @CloseTag AS ServiceHtml05,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo06)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue06, '')))) + @CloseTag AS ServiceHtml06,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo07)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue07, '')))) + @CloseTag AS ServiceHtml07,
			'a(n) ' + @OpenTag + LTRIM(RTRIM(ServiceInfo08)) + @CloseTag + ' of ' + @OpenTag + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue08, '')))) + @CloseTag AS ServiceHtml08,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo01)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue01, '')))) AS ServiceInfo01,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo02)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue02, '')))) AS ServiceInfo02,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo03)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue03, '')))) AS ServiceInfo03,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo04)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue04, '')))) AS ServiceInfo04,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo05)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue05, '')))) AS ServiceInfo05,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo06)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue06, '')))) AS ServiceInfo06,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo07)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue07, '')))) AS ServiceInfo07,
			'a(n) ' + LTRIM(RTRIM(ServiceInfo08)) + ' of ' + LTRIM(RTRIM(CONVERT(varchar(2048), NULLIF(ServiceValue08, '')))) AS ServiceInfo08
	INTO	#ServiceInfo
	FROM	ChartNet.EventDetail;
		
	CREATE UNIQUE CLUSTERED INDEX IX_#ServiceInfo ON #ServiceInfo (RowID);
		
	IF OBJECT_ID('tempdb..#ServiceDetail') IS NOT NULL
		DROP TABLE #ServiceDetail;	
		
	WITH ServiceHtml AS
	(
		SELECT	PursuitNumber,
				RowID, 
				ServiceDate,
				CONVERT(int, REPLACE(ServiceID, 'ServiceHtml', '')) AS ServiceID, 
				ServiceInfo
		FROM	#ServiceInfo AS p
				UNPIVOT
				(ServiceInfo FOR ServiceID IN	(
													ServiceHtml01, 
													ServiceHtml02, 
													ServiceHtml03,
													ServiceHtml04, 
													ServiceHtml05, 
													ServiceHtml06, 
													ServiceHtml07,
													ServiceHtml08
												)) AS u
	),
	ServiceInfo AS	
	(
		SELECT	PursuitNumber,
				RowID, 
				ServiceDate,
				CONVERT(int, REPLACE(ServiceID, 'ServiceInfo', '')) AS ServiceID, 
				ServiceInfo
		FROM	#ServiceInfo AS p
				UNPIVOT
				(ServiceInfo FOR ServiceID IN	(
													ServiceInfo01, 
													ServiceInfo02, 
													ServiceInfo03,
													ServiceInfo04, 
													ServiceInfo05, 
													ServiceInfo06, 
													ServiceInfo07,
													ServiceInfo08
												)) AS u
	)
	SELECT	CONVERT(varchar(2048), NULL) AS FinalHtml,
			CONVERT(varchar(2048), NULL) AS FinalInfo,
			CONVERT(bit, 0) AS IsFirst,
			CONVERT(bit, 0) AS IsLast,
			h.PursuitNumber,
			h.RowID, 
			h.ServiceDate,
			CONVERT(varchar(1024), h.ServiceInfo) AS ServiceHtml, 
			h.ServiceID, 
			CONVERT(varchar(1024), i.ServiceInfo) AS ServiceInfo
	INTO	#ServiceDetail
	FROM	ServiceHtml AS h
			INNER JOIN ServiceInfo AS i
					ON h.RowID = i.RowID AND
						h.ServiceID = i.ServiceID;

	CREATE UNIQUE CLUSTERED INDEX IX_#ServiceDetail ON #ServiceDetail (RowID, ServiceID);

	WITH FirstAndLast AS
	(
		SELECT	MIN(ServiceID) AS FirstID,
				MAX(ServiceID) AS LastID,
				RowID
		FROM	#ServiceDetail
		GROUP BY RowID
	)
	UPDATE	SD
	SET		IsFirst = CASE WHEN ServiceID = FirstID THEN 1 ELSE 0 END,
			IsLast = CASE WHEN ServiceID = LastID THEN 1 ELSE 0 END
	FROM	#ServiceDetail AS SD
			INNER JOIN FirstAndLast AS FAL
					ON SD.RowID = FAL.RowID

	DECLARE @FinalHtml varchar(2048);
	DECLARE @FinalInfo varchar(2048);

	UPDATE	#ServiceDetail
	SET		@FinalHtml = FinalHtml = CASE 
										WHEN IsFirst = 1 AND IsLast = 1
										THEN @OpenTag + 'Medical Chart Pursuit #' + PursuitNumber + @CloseTag + ' with ' + ServiceHtml + ' on ' + @OpenTag + CONVERT(varchar(2048), ServiceDate, 101) + @CloseTag + '.'
										WHEN IsFirst = 1
										THEN @OpenTag + 'Medical Chart Pursuit #' + PursuitNumber + @CloseTag + ' with ' + ServiceHtml
										WHEN IsLast = 1
										THEN @FinalHtml + ' and ' + ServiceHtml + ' on ' + @OpenTag + CONVERT(varchar(2048), ServiceDate, 101) + @CloseTag + '.'
										ELSE @FinalHtml + ', ' + ServiceHtml
										END,
			@FinalInfo = FinalInfo = CASE 
										WHEN IsFirst = 1 AND IsLast = 1
										THEN 'Medical Chart Pursuit #' + PursuitNumber + ' with ' + ServiceInfo + ' on ' + CONVERT(varchar(2048), ServiceDate, 101) + '.'
										WHEN IsFirst = 1
										THEN 'Medical Chart Pursuit #' + PursuitNumber + ' with ' + ServiceInfo
										WHEN IsLast = 1
										THEN @FinalInfo + ' and ' + ServiceInfo + ' on ' + CONVERT(varchar(2048), ServiceDate, 101) + '.'
										ELSE @FinalInfo + ', ' + ServiceInfo
										END 
	OPTION (MAXDOP 1);

	DROP INDEX IX_#ServiceDetail ON #ServiceDetail;

	DELETE FROM #ServiceDetail WHERE IsLast = 0;

	CREATE UNIQUE CLUSTERED INDEX IX_#ServiceDetail ON #ServiceDetail (RowID);

	IF OBJECT_ID('tempdb..#KeyDates') IS NOT NULL
		DROP TABLE #KeyDates;

	SELECT	RMD.DSMemberID,
			RMD.KeyDate,
			RMD.MetricID,
			MIN(RMD.ResultTypeID) AS ResultTypeID
	INTO	#KeyDates
	FROM	Result.MeasureDetail AS RMD
			INNER JOIN Result.ResultTypes AS RRT 
					ON RMD.ResultTypeID = RRT.ResultTypeID AND
						RRT.Abbrev IN ('H','M')
	WHERE	(RMD.DataRunID = @DataRunID)
	GROUP BY RMD.DSMemberID,
			RMD.KeyDate,
			RMD.MetricID;

	CREATE UNIQUE CLUSTERED INDEX IS_#KeyDates ON #KeyDates (DSMemberID, MetricID, KeyDate);

	BEGIN TRANSACTION TEvents;
	
	DELETE FROM Result.DataSetReviewerKey WHERE (DataRunID = @DataRunID);

	INSERT INTO Result.DataSetReviewerKey
			(DataRunID,
			DataSetID,
			DisplayName,
			FirstName,
			LastName,
			ReviewerID,
			UserName)
	SELECT	@DataRunID AS DataRunID,
			@DataSetID AS DataSetID,
			CONVERT(varchar(64), AbstractorName) AS DisplayName,
			CONVERT(varchar(32), LEFT(FirstName, 32)) AS FirstName,
			CONVERT(varchar(32), LEFT(LastName, 32)) AS LastName,
			AbstractorID AS ReviewerID,
			CONVERT(varchar(64), UserName) AS UserName
	FROM	ChartNet.EventAbstractors;

	DELETE FROM Result.MeasureEventDetail WHERE (DataRunID = @DataRunID) AND (ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE Abbrev IN ('H','M')));

	WITH MeasureEventDetail AS
	(
		SELECT	-1 AS BatchID,
				CVD.ServiceDate AS BeginDate,
				CVD.PursuitNumber AS ClaimNum,
				NULL AS ClaimTypeID,
				NULL AS Code,
				NULL AS CodeID,
				NULL AS CodeType,
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				SD.FinalInfo AS Descr,
				SD.FinalHtml AS DescrHtml,
				NULL AS DSClaimLineID,
				-1 AS DSEntityID,
				-1 AS DSEventID,
				RDSMK.DSMemberID,
				NULL AS EndDate,
				CVD.EntityInfo AS EntityDescr,
				-1 AS EntityID,
				NULL AS EventBaseID,
				CVD.EventInfo AS EventDescr,
				-1 AS EventID,
				0 AS Iteration,
				COALESCE(CVD.KeyDate, KD.KeyDate) AS KeyDate,
				255 AS MapTypeID,
				MX.MeasureID,
				MX.MetricID,
				KD.ResultTypeID,
				CVD.AbstractionDate AS ReviewDate,
				CVD.AbstractorID AS ReviewerID,
				CVD.ServiceDate AS ServDate
		FROM	#ServiceDetail AS SD
				INNER JOIN ChartNet.EventDetail AS CVD
						ON SD.RowID = CVD.RowID
				INNER JOIN Measure.Metrics AS MX
						ON CVD.Metric = MX.Abbrev
				INNER JOIN Measure.Measures AS MM
						ON MX.MeasureID = MM.MeasureID AND
							MM.MeasureSetID = @MeasureSetID                      
				INNER JOIN Result.DataSetMemberKey AS RDSMK
						ON CVD.CustomerMemberID = RDSMK.CustomerMemberID AND
							CVD.IhdsMemberID = RDSMK.IhdsMemberID AND
							RDSMK.DataRunID = @DataRunID
				LEFT OUTER JOIN #KeyDates AS KD
						ON RDSMK.DSMemberID = KD.DSMemberID AND
							MX.MetricID = KD.MetricID AND                        
							(
								(MM.Abbrev NOT IN ('FPC','PPC','MRP')) OR 
								(MM.Abbrev IN ('FPC','PPC') AND CVD.KeyDate BETWEEN DATEADD(dd, @FlexDaysforFPCPPC * -1, KD.KeyDate) AND DATEADD(dd, @FlexDaysforFPCPPC, KD.KeyDate)) OR
								(MM.Abbrev IN ('MRP') AND CVD.KeyDate BETWEEN DATEADD(dd, @FlexDaysForMRP * -1, KD.KeyDate) AND DATEADD(dd, @FlexDaysForMRP, KD.KeyDate))
							) 
							
	)
	INSERT INTO Result.MeasureEventDetail
			(BatchID,
			BeginDate,
			ClaimNum,
			ClaimTypeID,
			Code,
			CodeID,
			CodeType,
			DataRunID,
			DataSetID,
			Descr,
			DescrHtml,
			DSClaimLineID,
			DSEntityID,
			DSEventID,
			DSMemberID,
			EndDate,
			EntityDescr,
			EntityID,
			EventBaseID,
			EventDescr,
			EventID,
			Iteration,
			KeyDate,
			MapTypeID,
			MeasureID,
			MetricID,
			ResultTypeID,
			ReviewDate,
			ReviewerID,
			ServDate)
	SELECT	BatchID,
			BeginDate,
			ClaimNum,
			ClaimTypeID,
			Code,
			CodeID,
			CodeType,
			DataRunID,
			DataSetID,
			Descr,
			DescrHtml,
			DSClaimLineID,
			DSEntityID,
			DSEventID,
			DSMemberID,
			EndDate,
			EntityDescr,
			EntityID,
			EventBaseID,
			EventDescr,
			EventID,
			Iteration,
			KeyDate,
			MapTypeID,
			MeasureID,
			MetricID,
			ResultTypeID,
			ReviewDate,
			ReviewerID,
			ServDate 
	FROM	MeasureEventDetail 
	--KeyDate can be null for conversions that do not exist (such as CDC, HbA1c < 7 for Medicare). 
	--However, these records should not be copied to the final table
	WHERE	(KeyDate IS NOT NULL) AND (ResultTypeID IS NOT NULL)
	ORDER BY DSMemberID, 
			MetricID,
			KeyDate, 
			MapTypeID, 
			ServDate,
			EventDescr;
			
	COMMIT TRAN TEvents;	

	RETURN 0;
END

GO
GRANT VIEW DEFINITION ON  [ChartNet].[RefreshEvents] TO [db_executer]
GO
GRANT EXECUTE ON  [ChartNet].[RefreshEvents] TO [db_executer]
GO
GRANT EXECUTE ON  [ChartNet].[RefreshEvents] TO [Processor]
GO
