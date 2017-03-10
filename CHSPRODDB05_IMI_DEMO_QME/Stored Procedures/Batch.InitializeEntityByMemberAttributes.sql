SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/28/2011
-- Description:	Initializes entities based on member attributes and enrollment information (Gender and Age).  
--				(Date Comparer: 5083973D-945E-401A-A8B4-3CF5ACA57485)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityByMemberAttributes]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@CalculateXml = DR.CalculateXml,
				@DataRunID = DR.DataRunID,
				@DataSetID = DS.DataSetID,
				@EndInitSeedDate = DR.EndInitSeedDate,
				@IsLogged = DR.IsLogged,
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID,
				@SeedDate = DR.SeedDate
		FROM	Batch.[Batches] AS B 
				INNER JOIN Batch.DataRuns AS DR
						ON B.DataRunID = DR.DataRunID
				INNER JOIN Batch.DataSets AS DS 
						ON B.DataSetID = DS.DataSetID 
		WHERE (B.BatchID = @BatchID);
		
		----------------------------------------------------------------------------------------------
			
		--DECLARE @DateCompTypeE tinyint; --Entity
		--DECLARE @DateCompTypeN tinyint; --Enrollment
		--DECLARE @DateCompTypeS tinyint; --Seed Date
		--DECLARE @DateCompTypeV tinyint; --Event
		DECLARE @DateCompTypeM tinyint; --Member Demographics

		--SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		--SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		--SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		--SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
		SELECT @DateCompTypeM = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'M';

		----------------------------------------------------------------------------------------------

		DECLARE @DateComparerID int;
		SELECT	@DateComparerID = DateComparerID 
		FROM	Measure.DateComparers 
		WHERE	(DateComparerGuid = '5083973D-945E-401A-A8B4-3CF5ACA57485') AND
				(DateCompTypeID = @DateCompTypeM);

		SELECT DISTINCT
				ME.EntityID 
		INTO	#ValidEntities
		FROM	Measure.Entities AS ME
				INNER JOIN Proxy.EntityKey AS PEK
								ON ME.EntityID = PEK.EntityID
		WHERE	ME.MeasureSetID = @MeasureSetID AND
				ME.Iteration = @Iteration AND
				ME.IsEnabled = 1;
				
		CREATE UNIQUE CLUSTERED INDEX IX_#ValidEntities ON #ValidEntities (EntityID);
		
		SELECT	DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)) AS AfterDOBDate,
				MEC.Allow, MEC.AllowBeginDate, MEC.AllowEndDate, MEC.AllowServDate, MEC.AllowSupplemental,
				MEC.AllowXfers, M.DataSourceID, MEC.DateComparerID, MEC.DateComparerInfo, MEC.DateComparerLink,
				MEC.DaysMax, MEC.DaysMin, MA.DSMbrAttribID, M.DSMemberID, NULL AS DSProviderID,
				DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @BeginInitSeedDate)) AS EntityBeginDate,
				MEC.EntityCritID, 
				DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @EndInitSeedDate)) AS EntityEndDate,
				MEC.EntityID, MEC.IsForIndex, MA.MbrAttribID, MEC.RequirePaid, MEC.OptionNbr, ISNULL(MEC.QtyMax, 32767) AS QtyMax, ISNULL(MEC.QtyMin, 1) AS QtyMin,
				MEC.RankOrder, MA.DSMbrAttribID AS SourceID, CAST(NULL AS bigint) AS SourceLinkID
		INTO	#Base
		FROM	Measure.EntityCriteria AS MEC
				INNER JOIN #ValidEntities AS t
						ON MEC.EntityID = t.EntityID AND
							MEC.RankOrder = 1 AND
							MEC.DateComparerID = @DateComparerID AND
							MEC.IsEnabled = 1
				INNER JOIN Proxy.Members AS M
						ON 1 = 1
				INNER JOIN Proxy.MemberAttributes AS MA
						ON M.DSMemberID = MA.DSMemberID AND
							M.BatchID = MA.BatchID AND
							M.DataRunID = MA.DataRunID AND
							M.DataSetID = MA.DataSetID AND
							MEC.DateComparerInfo = CAST(MA.MbrAttribID AS int);

		DROP TABLE #ValidEntities;

		CREATE CLUSTERED INDEX IX_#Base ON #Base (DSMemberID, DateComparerID, DateComparerInfo, DateComparerLink, EntityBeginDate, EntityEndDate);

		WITH Results AS
		(
			SELECT DISTINCT --Distinct added due to group by on Product Line (effects LDM, RDM)
					t.Allow, 
					@BatchID AS BatchID,
					CASE 
						WHEN MIN(ISNULL(N.BeginDate, t.EntityBeginDate)) < t.EntityBeginDate 
						THEN t.EntityBeginDate 
						ELSE MIN(ISNULL(N.BeginDate, t.EntityBeginDate))
						END AS BeginDate,
					CASE 
						WHEN MIN(ISNULL(N.BeginDate, t.EntityBeginDate)) < t.EntityBeginDate 
						THEN t.EntityBeginDate 
						ELSE MIN(ISNULL(N.BeginDate, t.EntityBeginDate))
						END AS BeginOrigDate,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					MIN(t.DataSourceID) AS DataSourceID,
					t.DateComparerID,
					t.DateComparerInfo,
					t.DateComparerLink,
					NULL AS [Days],
					t.DSMemberID,
					t.DSProviderID,
					CASE 
						WHEN MAX(ISNULL(N.EndDate, t.EntityEndDate)) > t.EntityEndDate 
						THEN t.EntityEndDate 
						ELSE MAX(ISNULL(N.EndDate, t.EntityEndDate)) 
						END AS EndDate,
					CASE 
						WHEN MAX(ISNULL(N.EndDate, t.EntityEndDate)) > t.EntityEndDate 
						THEN t.EntityEndDate 
						ELSE MAX(ISNULL(N.EndDate, t.EntityEndDate)) 
						END AS EndOrigDate,
					CAST(NULL AS bigint) AS EntityBaseID,
					t.EntityBeginDate,
					t.EntityCritID, 
					t.EntityEndDate,
					t.EntityID,
					t.IsForIndex,
					MIN(t.MbrAttribID) AS MbrAttribID,
					t.OptionNbr, 
					1 AS Qty,
					t.QtyMax, 
					t.QtyMin,
					t.RankOrder,
					t.SourceID,
					t.SourceLinkID
			FROM	#Base AS t
					INNER JOIN Proxy.Enrollment AS N
							ON t.DSMemberID = N.DSMemberID AND
								N.BatchID = @BatchID AND
								N.DataRunID = @DataRunID AND
								N.DataSetID = @DataSetID AND
								(
									(N.BeginDate BETWEEN t.EntityBeginDate AND t.EntityEndDate) OR 
									(N.EndDate BETWEEN t.EntityBeginDate AND t.EntityEndDate) OR
									(t.EntityBeginDate BETWEEN N.BeginDate AND N.EndDate) OR
									(t.EntityEndDate BETWEEN N.BeginDate AND N.EndDate) OR 
									(N.BeginDate < t.EntityBeginDate AND N.EndDate > t.EntityEndDate) OR
									(N.BeginDate < t.EntityBeginDate AND N.EndDate IS NULL)
								)
					INNER JOIN Proxy.EnrollmentKey AS PNK
							ON N.BatchID = PNK.BatchID AND
								N.DataRunID = PNK.DataRunID AND
								N.DataSetID = PNK.DataSetID AND
								N.EnrollGroupID = PNK.EnrollGroupID
					INNER JOIN Product.PayerProductLines AS PPPL
							ON PNK.PayerID = PPPL.PayerID
			GROUP BY  t.Allow,
					t.DateComparerID,
					t.DateComparerInfo,
					t.DateComparerLink,
					t.DSMemberID,
					t.DSProviderID,
					t.EntityBeginDate,
					t.EntityCritID, 
					t.EntityEndDate,
					t.EntityID, 
					t.IsForIndex,
					t.OptionNbr,
					PPPL.ProductLineID, --Added 11/2/2011 (effects LDM, RDM)
					PNK.ProductTypeID, --Added 11/2/2011 (effects LDM, RDM)
					t.QtyMax, 
					t.QtyMin,
					t.RankOrder,
					t.SourceID,
					t.SourceLinkID
		)
		SELECT	t.Allow,
                t.BatchID,
                t.BeginDate,
                t.BeginOrigDate,
                t.DataRunID,
                t.DataSetID,
                t.DataSourceID,
                t.DateComparerID,
                t.DateComparerInfo,
                t.DateComparerLink,
                t.[Days],
                t.DSMemberID,
                t.DSProviderID,
                t.EndDate,
                t.EndOrigDate,
                t.EntityBaseID,
                t.EntityBeginDate,
                t.EntityCritID,
                t.EntityEndDate,
                t.EntityID,
                CASE WHEN @CalculateXml = 1 THEN (SELECT (SELECT MA.Abbrev AS attrib, MAC.Abbrev AS category, t.MbrAttribID AS id FOR XML RAW('memberattrib'), TYPE) FOR XML PATH('components'), TYPE) END AS EntityInfo,
				NULL AS EntityLinkInfo,
                t.IsForIndex,
				0 AS IsSupplemental,
                t.OptionNbr,
                t.Qty,
                t.QtyMax,
                t.QtyMin,
                t.RankOrder,
                t.SourceID,
                t.SourceLinkID
		FROM	Results AS t
				LEFT OUTER JOIN Member.Attributes AS MA WITH(NOLOCK)
						ON MA.MbrAttribID = t.MbrAttribID
				LEFT OUTER JOIN Member.AttributeCategories AS MAC WITH(NOLOCK)
						ON MAC.MbrAttribCtgyID = MA.MbrAttribCtgyID
		ORDER BY t.Allow DESC, t.EntityCritID, t.DSMemberID;
		
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;		
		
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@PerformRollback = 0,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END











GO
GRANT VIEW DEFINITION ON  [Batch].[InitializeEntityByMemberAttributes] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityByMemberAttributes] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[InitializeEntityByMemberAttributes] TO [Processor]
GO
