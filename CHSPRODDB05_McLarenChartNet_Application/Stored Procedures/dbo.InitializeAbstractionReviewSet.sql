SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InitializeAbstractionReviewSet]
(
    @Description NVARCHAR(50) = NULL,
	@StartDate smalldatetime,
	@EndDate smalldatetime,
	@SelectionPercentage decimal(8,6) = 0.10,
	@SelectionCriteria xml = NULL,
	@User nvarchar(100) = NULL,
	@HasDataEntry BIT = NULL,
	@IsCompliant BIT = NULL,
	@SelectAllComponents BIT = NULL,
	@AbstractionReviewSetID int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

    IF @User IS NULL
		SET @USER = SUSER_NAME();

	SET @StartDate = CONVERT(datetime, FLOOR(CONVERT(decimal(18, 6), @StartDate)));
	SET @EndDate = CONVERT(datetime, FLOOR(CONVERT(decimal(18, 6), @EndDate)));

	DECLARE @MeasureComponents TABLE
	(
		MeasureComponentID int NOT NULL,
		PRIMARY KEY CLUSTERED (MeasureComponentID)
	);

	DECLARE @Abstractors TABLE
	(
		AbstractorID int NOT NULL,
		PRIMARY KEY CLUSTERED (AbstractorID)
	);

	DECLARE @Products TABLE
	(
		ProductLine varchar(20) NOT NULL,
		Product varchar(20) NOT NULL,
		PRIMARY KEY CLUSTERED (ProductLine, Product)
	);

	DECLARE @ChartStatuses TABLE
    (
		ChartStatusValueID int NOT NULL,
		Description varchar(50) NOT NULL,
		PRIMARY KEY CLUSTERED (ChartStatusValueID)
	);

	IF @SelectionCriteria IS NOT NULL AND
		@SelectionCriteria.exist('criteria[1]/components[1]') = 1 
		BEGIN;
			WITH Components AS 
			(
				SELECT	component.value('@id', 'varchar(50)') AS ComponentName
				FROM	@SelectionCriteria.nodes('/criteria[1]/components[1]/component') AS c(component)
			)
			INSERT INTO @MeasureComponents
					(MeasureComponentID)
			SELECT	MC.MeasureComponentID
			FROM	Components AS C
					INNER JOIN dbo.MeasureComponent AS MC
							ON C.ComponentName = MC.ComponentName
			WHERE	MC.MeasureID IN (SELECT DISTINCT MeasureID FROM dbo.MemberMeasureSample UNION SELECT DISTINCT MeasureID FROM dbo.PursuitEvent) AND
					MC.EnabledOnReviews = 1 AND
					MC.EnabledOnWebsite = 1
			ORDER BY 1;
		END;
	ELSE
		BEGIN;
			INSERT INTO @MeasureComponents
					(MeasureComponentID)
			SELECT	MC.MeasureComponentID
			FROM	dbo.MeasureComponent AS MC
			WHERE	MC.MeasureID IN (SELECT DISTINCT MeasureID FROM dbo.MemberMeasureSample UNION SELECT DISTINCT MeasureID FROM dbo.PursuitEvent) AND
					MC.EnabledOnReviews = 1 AND
					MC.EnabledOnWebsite = 1;
		END;

	IF @SelectionCriteria IS NOT NULL AND
		@SelectionCriteria.exist('criteria[1]/abstractors[1]') = 1 
		BEGIN;
			WITH Abstractors AS 
			(
				SELECT	abstractor.value('@id', 'varchar(50)') AS AbstractorName
				FROM	@SelectionCriteria.nodes('/criteria[1]/abstractors[1]/abstractor') AS a(abstractor)
			)
			INSERT INTO @Abstractors
					(AbstractorID)
			SELECT	A.AbstractorID
			FROM	dbo.Abstractor AS A
					INNER JOIN Abstractors AS t
							ON t.AbstractorName = A.AbstractorName
			ORDER BY 1;
		END;
	ELSE
		BEGIN;
			INSERT INTO @Abstractors
					(AbstractorID)
			SELECT	A.AbstractorID
			FROM	dbo.Abstractor AS A
			ORDER BY 1;
		END;

	IF @SelectionCriteria IS NOT NULL AND
		@SelectionCriteria.exist('criteria[1]/products[1]') = 1 
		BEGIN;
			WITH Products AS 
			(
				SELECT	product.value('@id', 'varchar(20)') AS Product,
						product.value('@line', 'varchar(20)') AS ProductLine
				FROM	@SelectionCriteria.nodes('/criteria[1]/products[1]/product') AS p(product)
			),
			ValidProducts AS 
			(
				SELECT DISTINCT
						Product, ProductLine
				FROM	dbo.Member
				UNION
				SELECT DISTINCT
						Product, ProductLine
				FROM	dbo.MemberMeasureSample
			)
			INSERT INTO @Products
					(ProductLine,
					 Product)
			SELECT	P.ProductLine,
					P.Product
			FROM	Products AS P
					INNER JOIN ValidProducts AS VP
							ON P.Product = VP.Product AND
								P.ProductLine = VP.ProductLine
			ORDER BY 1, 2;
		END;
	ELSE
		BEGIN;
			WITH ValidProducts AS 
			(
				SELECT DISTINCT
						Product, ProductLine
				FROM	dbo.Member
				UNION
				SELECT DISTINCT
						Product, ProductLine
				FROM	dbo.MemberMeasureSample
			)
			INSERT INTO @Products
					(ProductLine,
					 Product)
			SELECT	VP.ProductLine,
					VP.Product
			FROM	ValidProducts AS VP
			ORDER BY 1, 2;
		END;

	IF @SelectionCriteria IS NOT NULL AND
		@SelectionCriteria.exist('criteria[1]/chartstatuses[1]') = 1 
		BEGIN;
			WITH ChartStatuses AS 
			(
				SELECT	chartstatus.value('@id', 'int') AS ChartStatusValueID,
						chartstatus.value('@name', 'varchar(50)') AS Description
				FROM	@SelectionCriteria.nodes('/criteria[1]/chartstatuses[1]/chartstatus') AS c(chartstatus)
			)
			INSERT INTO @ChartStatuses
			        (ChartStatusValueID, Description)
			SELECT	CST.ChartStatusValueID, CST.Description							
			FROM	ChartStatuses AS CST
					LEFT OUTER JOIN dbo.ChartStatusValue AS CSV
							ON CSV.ChartStatusValueID = CST.ChartStatusValueID
			WHERE	CST.ChartStatusValueID = -1 OR CSV.ChartStatusValueID IS NOT NULL
			ORDER BY 1;
		END;
	ELSE
		BEGIN;
			INSERT INTO @ChartStatuses
			        (ChartStatusValueID, Description)
			SELECT	CSV.ChartStatusValueID, CSV.Title
			FROM	dbo.ChartStatusValue AS CSV
			UNION
			SELECT	-1, 'None'
			ORDER BY 1;
		END;

	DECLARE @TranCount int = @@TRANCOUNT;

	BEGIN TRY;
		BEGIN TRANSACTION TReviewSet;

		DECLARE @OriginalValues TABLE
        (
			ProductLine varchar(20) NOT NULL,
			Product varchar(20) NOT NULL,
			MeasureComponentID int NOT NULL,
			AbstractorID int NOT NULL,
			SelectionPercentage decimal(8, 6)
		);

		IF @AbstractionReviewSetID IS NOT NULL AND
			EXISTS(SELECT TOP 1 1 FROM dbo.AbstractionReviewSet WHERE AbstractionReviewSetID = @AbstractionReviewSetID)
			BEGIN;

				IF EXISTS(SELECT TOP 1 1 FROM dbo.AbstractionReviewSet WHERE AbstractionReviewSetID = @AbstractionReviewSetID AND Finalized = 1)
					RAISERROR('Cannot change a finalized review set.', 16, 1);

				INSERT INTO @OriginalValues
				        (ProductLine,
				         Product,
				         MeasureComponentID,
				         AbstractorID,
				         SelectionPercentage)
				SELECT	ProductLine,
						Product, 
						MeasureComponentID,
						AbstractorID,
						SelectionPercentage
				FROM	dbo.AbstractionReviewSetConfiguration
				WHERE	(AbstractionReviewSetID = @AbstractionReviewSetID);

				DELETE FROM dbo.AbstractionReviewSetConfiguration WHERE AbstractionReviewSetID = @AbstractionReviewSetID;

				UPDATE	dbo.AbstractionReviewSet 
				SET		Description = @Description,
						StartDate = @StartDate,
						EndDate = @EndDate,
						SelectionPercentage = @SelectionPercentage,
						SelectionCriteria = @SelectionCriteria,
						HasDataEntry = @HasDataEntry,
						IsCompliant = @IsCompliant,
						SelectAllComponents = @SelectAllComponents,
						LastChangedDate = GETDATE(),
						LastChangedUser = @User
				WHERE	AbstractionReviewSetID = @AbstractionReviewSetID;

			END;
		ELSE
			BEGIN;

				INSERT INTO dbo.AbstractionReviewSet
						(StartDate,
						 EndDate,
						 SelectionPercentage,
						 SelectionCriteria,
						 HasDataEntry,
						 IsCompliant,
						 Finalized,
						 CreatedDate,
						 CreatedUser,
						 LastChangedDate,
						 LastChangedUser,
						 Description,
						 SelectAllComponents)
				VALUES	(@StartDate,
						@EndDate,
						@SelectionPercentage,
						@SelectionCriteria,
						@HasDataEntry,
						@IsCompliant,
						0,
						GETDATE(),
						@User,
						GETDATE(),
						@User,
						@Description,
						@SelectAllComponents);

				SET @AbstractionReviewSetID = SCOPE_IDENTITY();

			END;

		INSERT INTO dbo.AbstractionReviewSetConfiguration
				(AbstractionReviewSetID,
				ProductLine,
				Product,
				MeasureComponentID,
				AbstractorID,
				SelectionPercentage)
		SELECT DISTINCT
				@AbstractionReviewSetID AS AbstractionReviewSetID,
				MBR.ProductLine,
				MBR.Product,
				MC.MeasureComponentID,
				R.AbstractorID,
				ISNULL(OV.SelectionPercentage, @SelectionPercentage) AS SelectionPercentage
		FROM	dbo.PursuitEvent AS RV
				INNER JOIN dbo.Pursuit AS R
						ON RV.PursuitID = R.PursuitID
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
				INNER JOIN @Products AS tP
						ON MBR.Product = tP.Product AND
							MBR.ProductLine = tP.ProductLine
				INNER JOIN @Abstractors AS A
						ON A.AbstractorID = R.AbstractorID
				INNER JOIN dbo.MeasureComponent AS MC
						ON RV.MeasureID = MC.MeasureID
				INNER JOIN @MeasureComponents AS tMC
						ON MC.MeasureComponentID = tMC.MeasureComponentID
				INNER JOIN @ChartStatuses AS CST
						ON CST.ChartStatusValueID = ISNULL(RV.ChartStatusValueID, -1)
				INNER JOIN dbo.AbstractionStatus AS AST
						ON RV.AbstractionStatusID = AST.AbstractionStatusID
				LEFT OUTER JOIN @OriginalValues AS OV
						ON OV.AbstractorID = R.AbstractorID AND
							OV.MeasureComponentID = MC.MeasureComponentID AND
							OV.Product = MBR.Product AND
							OV.ProductLine = MBR.ProductLine
				OUTER APPLY (
								--Make sure at least one entry was made
								SELECT TOP 1 
										1 AS N 
								FROM	dbo.MedicalRecordComposite AS t1 
								WHERE	(t1.PursuitEventID = RV.PursuitEventID) AND	
										(t1.MeasureComponentID = MC.MeasureComponentID)
							) AS MRC
				OUTER APPLY (
								SELECT	SUM(CASE WHEN (tMMMS.AdministrativeHitCount < tMMMS.MedicalRecordHitCount AND tMMMS.HybridHitCount > 0) OR (tMMMS.MedicalRecordHit = 1 AND tMMMS.HybridHit = 1) THEN 1 ELSE 0 END) AS CountCompliant,
										SUM(CASE WHEN (tMMMS.HybridHitCount = 0) OR (tmmms.Denominator = 1 AND tMMMS.HybridHit = 0) THEN 1 ELSE 0 END) AS CountNotCompliant,
										COUNT(*) AS CountRecords
								FROM	dbo.MemberMeasureSample AS tMMS
										INNER JOIN dbo.MemberMeasureMetricScoring AS tMMMS
												ON tMMMS.MemberMeasureSampleID = tMMS.MemberMeasureSampleID
										INNER JOIN dbo.MeasureComponentMetrics AS tMCMX
												ON tMCMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID
								WHERE	tMMS.MemberID = R.MemberID AND
										tMMS.MeasureID = RV.MeasureID AND
										tMMS.EventDate = RV.EventDate AND
										tMCMX.MeasureComponentID = MC.MeasureComponentID
							) AS MMMS
				CROSS APPLY (
								--Get the latest status update date/time for the current abstraction status
								SELECT TOP 1 
										CONVERT(datetime, FLOOR(CONVERT(decimal(18, 6), t2.LogDate))) AS LogDate 
								FROM	dbo.PursuitEventStatusLog AS t2 
								WHERE	t2.PursuitEventID = RV.PursuitEventID AND 
										t2.AbstractionStatusID = RV.AbstractionStatusID AND
										t2.AbstractionStatusChanged = 1
								ORDER BY LogDate DESC
							) AS RVSL
		WHERE	(AST.IsCompleted = 1) AND
				(AST.IsOmittedIRR = 0) AND
				((@HasDataEntry IS NULL) OR (@HasDataEntry = 1 AND MRC.N = 1) OR (@HasDataEntry = 0 AND MRC.N IS NULL)) AND
				((@IsCompliant IS NULL) OR (@IsCompliant = 1 AND ISNULL(MMMS.CountCompliant, 0) > 0) OR (@IsCompliant = 0 AND ISNULL(MMMS.CountNotCompliant, 0) > 0)) AND
				(RVSL.LogDate BETWEEN @StartDate AND @EndDate);

		SELECT @AbstractionReviewSetID AS AbstractionReviewSetID;

		COMMIT TRANSACTION TReviewSet;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > @TranCount
			ROLLBACK;

		DECLARE @ErrMsg nvarchar(max);
		SET @ErrMsg = ERROR_MESSAGE();

		RAISERROR (@ErrMsg, 16, 1);
		PRINT @ErrMsg;
	END CATCH;
END
GO
