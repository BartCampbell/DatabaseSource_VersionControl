SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/21/2011
-- Description:	Initializes entities based on member demographic information (Gender and Age).  
--				(Date Comparer: AAB7602B-91AD-4B16-8B09-5280ADADCF1E)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEntityByMemberGenderAndAge]
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
		WHERE	(DateComparerGuid = 'AAB7602B-91AD-4B16-8B09-5280ADADCF1E') AND
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
		
		--Switched the order of the months and days DATEADD functions, 12/6/2012
		SELECT	DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)) AS AfterDOBDate,
				MEC.Allow, MEC.AllowBeginDate, MEC.AllowEndDate, MEC.AllowServDate, MEC.AllowSupplemental,
				MEC.AllowXfers, M.DataSourceID, MEC.DateComparerID, MEC.DateComparerInfo, MEC.DateComparerLink,
				MEC.DaysMax, MEC.DaysMin, M.DOB, M.DSMemberID, NULL AS DSProviderID,
				DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @SeedDate)) AS EntityBeginDate,
				MEC.EntityCritID, 
				DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @SeedDate)) AS EntityEndDate,
				MEC.EntityID, M.Gender, MEC.IsForIndex, MEC.RequirePaid, MEC.OptionNbr, ISNULL(MEC.QtyMax, 32767) AS QtyMax, ISNULL(MEC.QtyMin, 1) AS QtyMin,
				MEC.RankOrder, CAST(NULL AS bigint) AS SourceLinkID
		INTO	#Base
		FROM	Measure.EntityCriteria AS MEC
				INNER JOIN #ValidEntities AS t
						ON MEC.EntityID = t.EntityID AND
							MEC.RankOrder = 1 AND
							MEC.DateComparerID = @DateComparerID AND
							MEC.IsEnabled = 1
				INNER JOIN Proxy.Members AS M
						ON	(
								(MEC.DateComparerInfo = -1) OR
								(
									(MEC.DateComparerInfo BETWEEN 0 AND 255) AND
									(MEC.DateComparerInfo = CAST(M.Gender AS int))
								)
							)
		WHERE	(
					DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)) /*AfterDOBDate*/ 
							BETWEEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, @SeedDate)) /*EntityBeginDate*/ AND
									DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, @SeedDate)) /*EntityEndDate*/
				);

		DROP TABLE #ValidEntities;

		SELECT	t.Allow, 
				@BatchID AS BatchID,
				t.AfterDOBDate AS BeginDate,
				t.AfterDOBDate AS BeginOrigDate,
				@DataRunID AS DataRunID,
				@DataSetID AS DataSetID,
				t.DataSourceID,
				t.DateComparerID,
				t.DateComparerInfo,
				t.DateComparerLink,
				NULL AS [Days],
				t.DSMemberID,
				CAST(NULL AS bigint) AS DSProviderID,
				t.AfterDOBDate AS EndDate,
				t.AfterDOBDate AS EndOrigDate,
				CAST(NULL AS bigint) AS EntityBaseID,
				t.EntityBeginDate,
				t.EntityCritID, 
				t.EntityEndDate,
				t.EntityID, 
				CASE WHEN @CalculateXml = 1 THEN (SELECT (SELECT dbo.ConvertDateToYYYYMMDD(t.DOB) AS dob, MG.Abbrev AS gender FOR XML RAW('member'), TYPE) FOR XML PATH('components'), TYPE) END AS EntityInfo,
				NULL AS EntityLinkInfo,
				t.IsForIndex,
				0 AS IsSupplemental,
				t.OptionNbr, 
				1 AS Qty,
				t.QtyMax, 
				t.QtyMin,
				t.RankOrder,
				t.DSMemberID AS SourceID,
				t.SourceLinkID
		FROM	#Base AS t
				LEFT OUTER JOIN Member.Genders AS MG WITH(NOLOCK)
						ON MG.Gender = t.Gender
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
GRANT EXECUTE ON  [Batch].[InitializeEntityByMemberGenderAndAge] TO [Processor]
GO
