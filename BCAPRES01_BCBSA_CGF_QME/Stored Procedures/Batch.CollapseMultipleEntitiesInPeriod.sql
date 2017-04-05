SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/31/2017
-- Description:	Collapses multiple entities down to a single entity, by applying the collapse period from earliest to latest date.
-- =============================================
CREATE PROCEDURE [Batch].[CollapseMultipleEntitiesInPeriod]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
)
AS
BEGIN
	-- To Debug, set @CustomerMemberID to a value other than NULL... ------------------------
	DECLARE @CustomerMemberID varchar(32);
	DECLARE @DSMemberID bigint;

	SELECT @DSMemberID = MM.DSMemberID FROM Member.Members AS MM WHERE MM.CustomerMemberID = @CustomerMemberID;
	-----------------------------------------------------------------------------------------

	SET NOCOUNT ON;
	
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CollapseMultipleEntitiesInPeriod'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
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


		SELECT	DATEADD(DAY, ME.CollapseDays, DATEADD(MONTH, ME.CollapseMonths, ISNULL(PE.EndDate, BeginDate))) AS CollapseDate,
				CONVERT(bigint, NULL) AS CollapseDSEntityID,
				CONVERT(bigint, NULL) AS CollapseID,
				PE.DSEntityID, 
				PE.DSMemberID,
				PE.EntityID,
				ISNULL(PE.EndDate, BeginDate) AS EvalDate, 
				IDENTITY(bigint, 1, 1) AS ID
		INTO	#Entities
		FROM	Proxy.Entities AS PE
				INNER JOIN Measure.Entities AS ME WITH(NOLOCK)
						ON ME.EntityID = PE.EntityID 
		WHERE	(PE.BatchID = @BatchID) AND
				(PE.DataRunID = @DataRunID) AND
				(PE.DataSetID = @DataSetID) AND
				(
					(ME.CollapseDays > 0) OR 
					(ME.CollapseMonths > 0)
				) AND
				(ME.IsEnabled = 1) AND
				(PE.Iteration = @Iteration) AND
				(ME.MeasureSetID = @MeasureSetID)
		ORDER BY DSMemberID, EntityID, EvalDate, DSEntityID;

		CREATE UNIQUE CLUSTERED INDEX IX_#Entities ON #Entities (DSMemberID, EntityID, EvalDate, DSEntityID);


		DECLARE @LastCollapseDate datetime;
		DECLARE @LastCollapseDSEntityID bigint;
		DECLARE @LastCollapseID bigint
		DECLARE @LastDSMemberID bigint;
		DECLARE @LastEntityID int;
		DECLARE @LastID bigint;

		UPDATE	t
		SET		@LastCollapseID = CollapseID =	CASE WHEN @LastID IS NULL OR
															@LastCollapseDate < t.EvalDate OR
															@LastDSMemberID <> t.DSMemberID OR
															@LastEntityID <> t.EntityID
													 THEN ISNULL(@LastCollapseID, 0) + 1
													 ELSE @LastCollapseID
													 END,
				@LastCollapseDSEntityID = CollapseDSEntityID =	CASE WHEN @LastID IS NULL OR
																			@LastCollapseDate < t.EvalDate OR
																			@LastDSMemberID <> t.DSMemberID OR
																			@LastEntityID <> t.EntityID
																	 THEN DSEntityID
																	 ELSE @LastCollapseDSEntityID
																	 END,
				@LastCollapseDate = CASE WHEN @LastID IS NULL OR
												@LastCollapseDate < t.EvalDate OR
												@LastDSMemberID <> t.DSMemberID OR
												@LastEntityID <> t.EntityID
										 THEN CollapseDate
										 ELSE @LastCollapseDate
										 END,
				@LastDSMemberID = t.DSMemberID,
				@LastEntityID = t.EntityID,
				@LastID = t.ID
		FROM	#Entities AS t
		OPTION(MAXDOP 1);


		IF @DSMemberID IS NOT NULL
			SELECT * FROM #Entities WHERE DSMemberID BETWEEN @DSMemberID /*- 10*/ AND @DSMemberID ORDER BY ID;

		DROP INDEX IX_#Entities ON #Entities;
		CREATE UNIQUE CLUSTERED INDEX IX_#Entities ON #Entities (DSEntityID, CollapseDSEntityID);

		DELETE 
		FROM	Proxy.Entities 
		WHERE	BatchID = @BatchID AND 
				DataRunID = @DataRunID AND 
				DataSetID = @DataSetID AND 
				DSEntityID IN (SELECT DISTINCT DSEntityID FROM #Entities WHERE DSEntityID <> CollapseDSEntityID);
				
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
