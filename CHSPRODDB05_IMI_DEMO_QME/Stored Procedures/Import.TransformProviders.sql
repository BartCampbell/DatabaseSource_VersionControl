SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Transforms provider data from dbo.Provider into the Provider.Providers table, as well as setting up provider specialties.
-- =============================================
CREATE PROCEDURE [Import].[TransformProviders]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
	
		--Purge Provider Specialty records for the specified DataSet, if any
		DELETE FROM Provider.ProviderSpecialties WHERE DataSetID = @DataSetID;
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Provider.ProviderSpecialties)
			TRUNCATE TABLE Provider.ProviderSpecialties;
		
		
		--Purge Provider records for the specified DataSet, if any
		DELETE FROM Provider.Providers WHERE DataSetID = @DataSetID;
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Provider.Providers)
			TRUNCATE TABLE Provider.Providers;
			
		--Build a temp table for the Providers table in the engine...
		IF OBJECT_ID('tempdb..#Provider_Providers') IS NOT NULL
			DROP TABLE #Provider_Providers;

		CREATE TABLE #Provider_Providers	
		(
			BitSpecialties bigint NOT NULL DEFAULT(0),
			DSProviderID bigint NOT NULL,
			IhdsProviderID int NOT NULL,
			ProviderID int NOT NULL
		);

		--Populate Providers
		INSERT INTO Provider.Providers
				(DataSetID, DataSourceID, IhdsProviderID, ProviderID)
		OUTPUT	INSERTED.DSProviderID, INSERTED.IhdsProviderID, INSERTED.ProviderID INTO #Provider_Providers (DSProviderID, IhdsProviderID, ProviderID)
		SELECT DISTINCT
				@DataSetID,
				BDSS.DataSourceID,
				ihds_prov_id,
				ProviderID 	
		FROM	dbo.Provider AS P
				INNER JOIN Batch.DataSetSources AS BDSS
						ON P.DataSource = BDSS.DataSource AND
							BDSS.IsSupplemental = 0 AND               
							BDSS.DataSetID = @DataSetID AND
							BDSS.SourceSchema = 'dbo' AND
							BDSS.SourceTable = 'Provider'                          
		WHERE	((@HedisMeasureID IS NULL) OR (P.HedisMeasureID = @HedisMeasureID))
		ORDER BY ProviderID
		OPTION(RECOMPILE);
		
		CREATE UNIQUE CLUSTERED INDEX IX_#Provider_Providers ON #Provider_Providers (IhdsProviderID, ProviderID);

		WITH ProviderSpecialtyColumns AS
		(
			SELECT	CAST('PCP' AS varchar(16)) AS Specialty, 
					CAST('PCPFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('OBGYN' AS varchar(16)) AS Specialty, 
					CAST('OBGynFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('MH' AS varchar(16)) AS Specialty, 
					CAST('MentalHealthFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('EyeCare' AS varchar(16)) AS Specialty, 
					CAST('EyeCareFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Dentist' AS varchar(16)) AS Specialty, 
					CAST('DentistFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Neph' AS varchar(16)) AS Specialty, 
					CAST('NephrologistFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Anesth' AS varchar(16)) AS Specialty, 
					CAST('AnesthesiologistFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('NPR' AS varchar(16)) AS Specialty, 
					CAST('NursePractFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('PAS' AS varchar(16)) AS Specialty, 
					CAST('PhysicianAsstFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('PCP' AS varchar(16)) AS Specialty, 
					CAST('PCPFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Prescribe' AS varchar(16)) AS Specialty, 
					CAST('ProviderPrescribingPrivFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('ClinicPharm' AS varchar(16)) AS Specialty, 
					CAST('ClinicalPharmacistFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Hosp' AS varchar(16)) AS Specialty, 
					CAST('HospitalFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('SNF' AS varchar(16)) AS Specialty, 
					CAST('SkilledNursingFacFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('Surg' AS varchar(16)) AS Specialty, 
					CAST('SurgeonFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('RN' AS varchar(16)) AS Specialty, 
					CAST('RegisteredNurseFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('DME' AS varchar(16)) AS Specialty, 
					CAST('DurableMedEquipmentFlag' AS nvarchar(128)) AS ColumnName
			UNION
			SELECT	CAST('AMB' AS varchar(16)) AS Specialty, 
					CAST('AmbulanceFlag' AS nvarchar(128)) AS ColumnName
		)
		SELECT	t.ColumnName, 
				IDENTITY(smallint, 1, 1) AS ID,
				t.Specialty, 
				PS.SpecialtyID
		INTO	#Specialties
		FROM	ProviderSpecialtyColumns AS t
				INNER JOIN Provider.Specialties AS PS WITH(NOLOCK)
						ON t.Specialty = PS.Abbrev
				INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
						ON t.ColumnName = C.COLUMN_NAME AND
							C.TABLE_NAME = 'Provider' AND
							C.TABLE_SCHEMA = 'dbo';
			
		CREATE UNIQUE CLUSTERED INDEX IX_#Specialties ON #Specialties (ID);
		
		
		IF OBJECT_ID('tempdb..#Provider_ProviderSpecialties') IS NOT NULL
			DROP TABLE #Provider_ProviderSpecialties;

		CREATE TABLE #Provider_ProviderSpecialties	
		(
			DSProviderID bigint NOT NULL,
			SpecialtyID smallint NOT NULL
		);

		DECLARE @ID smallint;
		DECLARE @MaxID smallint;
		
		SELECT @MaxID = MAX(ID) FROM #Specialties;
		
		DECLARE @ColumnName nvarchar(128);
		DECLARE @Specialty varchar(16);
		DECLARE @SpecialtyID smallint;
		DECLARE @Sql nvarchar(max);
				
		WHILE 1 = 1
			BEGIN
				SET @ID = ISNULL(@ID, 0) + 1;
				
				IF @ID > @MaxID 
					BREAK;
			
				SELECT	@ColumnName = ColumnName,
						@Specialty = Specialty,
						@SpecialtyID = SpecialtyID
				FROM	#Specialties
				WHERE	(ID = @ID);
				
				SET @Sql =	'INSERT INTO Provider.ProviderSpecialties 
									(DataSetID, DSProviderID, SpecialtyID)
							OUTPUT	INSERTED.DSProviderID, INSERTED.SpecialtyID INTO #Provider_ProviderSpecialties (DSProviderID, SpecialtyID)
							SELECT	' + CAST(@DataSetID AS nvarchar(max)) + ' AS DataSetID,
									P.DSProviderID, 
									' + CAST(@SpecialtyID AS nvarchar(max)) + ' AS SpecialtyID 
							FROM	dbo.Provider AS t
									INNER JOIN #Provider_Providers AS P
											ON t.ProviderID = P.ProviderID AND
												t.ihds_prov_id = P.IhdsProviderID
							WHERE	(t.' + QUOTENAME(@ColumnName) + ' = ''Y'');';
							
				EXEC sys.sp_executesql @sql;
							
			END;

		DROP INDEX IX_#Provider_Providers ON #Provider_Providers;
		CREATE UNIQUE CLUSTERED INDEX IX_#Provider_Providers ON #Provider_Providers (DSProviderID);

		WITH Specialties AS 
		(
			SELECT	SUM(DISTINCT PS.BitValue) AS BitSpecialties,
					PPS.DSProviderID
			FROM	#Provider_ProviderSpecialties AS PPS
					INNER JOIN Provider.Specialties AS PS WITH(NOLOCK)
							ON PS.SpecialtyID = PPS.SpecialtyID
			GROUP BY PPS.DSProviderID
		)
		UPDATE	PP
		SET		BitSpecialties = t.BitSpecialties
		FROM	#Provider_Providers AS PP
				INNER JOIN Specialties AS t
						ON t.DSProviderID = PP.DSProviderID;

		UPDATE	PP
		SET		BitSpecialties = t.BitSpecialties
		FROM	Provider.Providers AS PP
				INNER JOIN #Provider_Providers AS t
						ON t.DSProviderID = PP.DSProviderID;

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
GRANT VIEW DEFINITION ON  [Import].[TransformProviders] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformProviders] TO [db_executer]
GO
GRANT EXECUTE ON  [Import].[TransformProviders] TO [Processor]
GO
