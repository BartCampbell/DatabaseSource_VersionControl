SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/24/2011
-- Description:	Imports the current data from the standard tables into the measure compliance engine.
-- =============================================
CREATE PROCEDURE [Batch].[ImportDataSet]
(
	@DataSetID int = NULL OUTPUT,
	@DefaultIhdsProviderId int = NULL,
	@HedisMeasureID varchar(10) = NULL,
	@OwnerID int,
	@ShowRecord bit = 0,
	@Top int = 0
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @DataSetGuid uniqueidentifier;

	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);

	DECLARE @Result int;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ImportDataSet'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		DECLARE @UserDate datetime;
		DECLARE @UserName nvarchar(128);

		SELECT	@UserDate = GETDATE(),
				@UserName = SUSER_SNAME();
		
		IF (@DataSetID IS NULL) AND 
			(@OwnerID IS NOT NULL) AND EXISTS(SELECT TOP (1) 1 FROM Batch.DataOwners WHERE OwnerID = @OwnerID)
			BEGIN;
			
				EXEC @Result = Batch.CreateDataSet  
								@DataSetGuid = @DataSetGuid OUTPUT, 
								@DataSetID = @DataSetID OUTPUT, 
								@DefaultIhdsProviderId = @DefaultIhdsProviderID,
								@OwnerID = @OwnerID;
				
				IF @Result <> 0 OR @DataSetID IS NULL
					RAISERROR('Unable to create dataset.', 16, 1);

				BEGIN TRY;
					SET @LogDescr = 'Import of data SET-' + CAST(@DataSetGuid AS varchar(36)) + ' started.';
										
					EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
														@CountRecords = -1, 
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogEndTime,
														@EntryXrefGuid = @LogEntryXrefGuid, 
														@IsSuccess = 1,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;
					
					-------------------------------------------------------------------------------------------------------
					
					DECLARE @ClaimTypeE tinyint
					DECLARE @ClaimTypeL tinyint
					DECLARE @ClaimTypeP tinyint
					
					SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E'
					SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L'
					SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P'
					
					DECLARE @CodeType1 tinyint
					DECLARE @CodeType2 tinyint
					DECLARE @CodeType0 tinyint
					DECLARE @CodeTypeR tinyint
					DECLARE @CodeTypeB tinyint
					DECLARE @CodeTypeD tinyint
					DECLARE @CodeTypeP tinyint
					DECLARE @CodeTypeC tinyint
					DECLARE @CodeTypeM tinyint
					DECLARE @CodeTypeH tinyint
					DECLARE @CodeTypeS tinyint
					DECLARE @CodeTypeX tinyint
					DECLARE @CodeTypeN tinyint
					DECLARE @CodeTypeL tinyint
					
					SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1'
					SELECT @CodeType2 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '2'
					SELECT @CodeType0 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '0'
					SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R'
					SELECT @CodeTypeB = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'B'
					SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D'
					SELECT @CodeTypeP = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P'
					SELECT @CodeTypeC = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'C'
					SELECT @CodeTypeM = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'M'
					SELECT @CodeTypeH = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'H'
					SELECT @CodeTypeS = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'S'
					SELECT @CodeTypeX = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'X'
					SELECT @CodeTypeN = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'N'
					SELECT @CodeTypeL = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'L'
					
					DECLARE @CountRecords int;
					DECLARE @CountAllRecords int;
					DECLARE @ProcBeginTime datetime;
					DECLARE @ProcEndTime datetime;
										
					--BEGIN TRANSACTION T1; --Logs get too big when number of records is large
					
					-------------------------------------------------------------------------------------------------------

					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.IdentifyDataSources @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
					
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Batch.DataSetSources WHERE DataSetID = @DataSetID;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - Identifying data sources succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = 'CE378225-EB9C-4DCF-BF6F-477600116C66', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'IdentifyDataSources',
														@SrcObjectSchema = 'Import',
														@StepNbr = 1,
														@StepTot = 7;

					-------------------------------------------------------------------------------------------------------
					
					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformMembers @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
					
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Member.Members WHERE DataSetID = @DataSetID;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of members succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = 'DF08B8D8-5D34-4D68-B110-278CCB43161A', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'TransformMembers',
														@SrcObjectSchema = 'Import',
														@StepNbr = 2,
														@StepTot = 7;
														
					-------------------------------------------------------------------------------------------------------
					
					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformEnrollment @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
										
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Member.Enrollment AS ME INNER JOIN Member.Members AS MM ON ME.DSMemberID = MM.DSMemberID WHERE MM.DataSetID = @DataSetID;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of enrollment succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = '098E6385-6FB9-40D5-B3AF-22BC0A201B8E', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'TransformEnrollment',
														@SrcObjectSchema = 'Import',
														@StepNbr = 3,
														@StepTot = 7;
														
					-------------------------------------------------------------------------------------------------------
					
					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformProviders @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
										
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Provider.Providers WHERE DataSetID = @DataSetID;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of providers succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = 'E42ECBD2-5D6B-4A18-8EBC-4FC8E2684A30', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'TransformProviders',
														@SrcObjectSchema = 'Import',
														@StepNbr = 4,
														@StepTot = 7;
														
					-------------------------------------------------------------------------------------------------------
					
					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformEncounterClaims @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
										
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Claim.ClaimLines AS CL INNER JOIN Member.Members AS MM ON CL.DSMemberID = MM.DSMemberID WHERE MM.DataSetID = @DataSetID AND CL.ClaimTypeID = @ClaimTypeE;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of encounter claims succeeded.',
														@EndTime = @ProcEndTime,
														@EntryXrefGuid = 'DE29E898-FBDC-42DD-853B-A544B2C04964', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema, 
														@IsSuccess = 1,
														@SrcObjectName = 'TransformEncounterClaims',
														@SrcObjectSchema = 'Import',
														@StepNbr = 5,
														@StepTot = 7;
														
					-------------------------------------------------------------------------------------------------------
					
					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformPharmacyClaims @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
					
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Claim.ClaimLines AS CL INNER JOIN Member.Members AS MM ON CL.DSMemberID = MM.DSMemberID WHERE MM.DataSetID = @DataSetID AND CL.ClaimTypeID = @ClaimTypeP;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of pharmacy claims succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = '1349A03E-B997-40FF-9B2C-8E61143562B3', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'TransformPharmacyClaims',
														@SrcObjectSchema = 'Import',
														@StepNbr = 6,
														@StepTot = 7;
														
					-------------------------------------------------------------------------------------------------------

					SET @ProcBeginTime = GETDATE();
					
					EXEC @Result = Import.TransformLabClaims  @DataSetID = @DataSetID, @HedisMeasureID = @HedisMeasureID;
												
					SET @ProcEndTime = GETDATE();
					
					SELECT @CountRecords = COUNT(*) FROM Claim.ClaimLines AS CL INNER JOIN Member.Members AS MM ON CL.DSMemberID = MM.DSMemberID WHERE MM.DataSetID = @DataSetID AND CL.ClaimTypeID = @ClaimTypeL;
					SET @CountAllRecords = ISNULL(@CountAllRecords, 0) + @CountRecords;
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginTime,
														@CountRecords = @CountRecords,
														@DataSetID = @DataSetID,
														@Descr = ' - The transformation of lab claims succeeded.',
														@EndTime = @ProcEndTime, 
														@EntryXrefGuid = 'AE786268-9EDB-4ED2-9E55-4DBFCC5A3EC9', 
														@ExecObjectName = @LogObjectName,
														@ExecObjectSchema = @LogObjectSchema,
														@IsSuccess = 1,
														@SrcObjectName = 'TransformLabClaims',
														@SrcObjectSchema = 'Import',
														@StepNbr = 7,
														@StepTot = 7;	
															
					--Update DataSet Counts--------------------------------------------------------------------------------
					WITH Members AS
					(
						SELECT	DSMemberID
						FROM	Member.Members
						WHERE	DataSetID = @DataSetID 
					)
					UPDATE	Batch.DataSets
					SET		CountClaimCodes = 
											(	
												SELECT	COUNT(DISTINCT CC.DSClaimCodeID) AS Cnt 
												FROM	Claim.ClaimCodes AS CC 
														INNER JOIN Claim.ClaimLines AS CL 
																ON CC.DSClaimLineID = CL.DSClaimLineID 
														INNER JOIN Members AS M
																ON CL.DSMemberID = M.DSMemberID 
											),
							CountClaimLines = 
											(	
												SELECT	COUNT(DISTINCT CL.DSClaimLineID) AS Cnt 
												FROM	Claim.ClaimLines AS CL
														INNER JOIN Members AS M
																ON CL.DSMemberID = M.DSMemberID 
											),
							CountClaims = 
											(	
												SELECT	COUNT(DISTINCT C.DSClaimID) AS Cnt 
												FROM	Claim.Claims AS C
														INNER JOIN Claim.ClaimLines AS CL
																ON C.DSClaimID = CL.DSClaimID 
														INNER JOIN Members AS M
																ON CL.DSMemberID = M.DSMemberID 
											),
							CountEnrollment = 
											(
												SELECT	COUNT(DISTINCT E.EnrollItemID)
												FROM	Member.Enrollment AS E
														INNER JOIN Members AS M
																ON E.DSMemberID = M.DSMemberID 
											),
							CountMemberAttribs =
											(
												SELECT	COUNT(DISTINCT A.DSMbrAttribID)
												FROM	Member.MemberAttributes AS A
														INNER JOIN Members AS M
																ON A.DSMemberID = M.DSMemberID 
											),
							CountMembers =
											(
												SELECT	COUNT(*)
												FROM	Members
											),
							CountProviders =
											(
												SELECT	COUNT(*)
												FROM	Provider.Providers 
												WHERE	DataSetID = @DataSetID 
											)
					WHERE	DataSetID = @DataSetID 					
					
					IF @ShowRecord = 1
						SELECT * FROM Batch.DataSets WHERE DataSetID = @DataSetID;
					
					--COMMIT TRANSACTION T1;--Logs get too big when number of records is large
								
					IF @Top > 0
					BEGIN;
						SELECT TOP (@top) 'Member.Members' AS TableName, * FROM Member.Members;
						SELECT TOP (@top) 'Member.MemberAttributes' AS TableName, * FROM Member.MemberAttributes;
						SELECT TOP (@top) 'Member.Enrollment' AS TableName, * FROM Member.Enrollment ;
						SELECT TOP (@top) 'Member.EnrollmentBenefits' AS TableName, * FROM Member.EnrollmentBenefits ;
						SELECT TOP (@top) 'Provider.Providers' AS TableName, * FROM Provider.Providers;
						SELECT TOP (@top) 'Provider.ProviderSpecialties' AS TableName, * FROM Provider.ProviderSpecialties;
						SELECT TOP (@top) 'Claim.Claims' AS TableName, * FROM Claim.Claims --WHERE ClaimTypeID = @ClaimTypeL;
						SELECT TOP (@top) 'Claim.ClaimLines' AS TableName, * FROM Claim.ClaimLines --WHERE ClaimTypeID = @ClaimTypeL;
						SELECT TOP (@top) 'Claim.ClaimCodes' AS TableName, * FROM Claim.ClaimCodes --WHERE DSClaimLineID IN (SELECT DSClaimLineID FROM Claim.ClaimLines WHERE ClaimTypeID = @ClaimTypeL)
						SELECT TOP (@Top) 'Claim.Codes' AS TableName, * FROM Claim.Codes;
					END;

					SET @LogDescr = 'Import of data SET-' + CAST(@DataSetGuid AS varchar(36)) + ' completed succcessfully.'; 
					SET @LogEndTime = GETDATE();
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
														@CountRecords = @CountAllRecords,
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogEndTime, 
														@EntryXrefGuid = @LogEntryXrefGuid,
														@IsSuccess = 1,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;

					EXEC @Result = Claim.RefreshCodes @DataSetID = @DataSetID;

					RETURN 0;
				END TRY
				BEGIN CATCH;
					IF @@TRANCOUNT > 0
						ROLLBACK;
						
					DECLARE @ErrorLine int;
					DECLARE @ErrorLogID int;
					DECLARE @ErrorMessage nvarchar(max);
					DECLARE @ErrorNumber int;
					DECLARE @ErrorSeverity int;
					DECLARE @ErrorSource nvarchar(512);
					DECLARE @ErrorState int;
					
					DECLARE @ErrorResult int;
					
					SELECT	@ErrorLine = ERROR_LINE(),
							@ErrorMessage = ERROR_MESSAGE(),
							@ErrorNumber = ERROR_NUMBER(),
							@ErrorSeverity = ERROR_SEVERITY(),
							@ErrorSource = ERROR_PROCEDURE(),
							@ErrorState = ERROR_STATE();
							
					EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
															@Message = @ErrorMessage,
															@ErrorNumber = @ErrorNumber,
															@ErrorType = 'Q',
															@ErrLogID = @ErrorLogID OUTPUT,
															@Severity = @ErrorSeverity,
															@Source = @ErrorSource,
															@State = @ErrorState,
															@PerformRollback = 0;
					
					
					SET @LogEndTime = GETDATE();
					SET @LogDescr = 'Import of data SET-' + CAST(@DataSetGuid AS varchar(36)) + ' failed!'; 
					
					EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
														@CountRecords = -1, 
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogBeginTime,
														@EntryXrefGuid = @LogEntryXrefGuid,
														@ErrLogID = @ErrorLogID,
														@IsSuccess = 0,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;
																
					SET @ErrorMessage = REPLACE(@LogDescr, '!', ': ') + @ErrorMessage + ' (Error: ' + CAST(@ErrorNumber AS nvarchar) + ')';
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
				END CATCH;
		
				
			END;
		ELSE
			RAISERROR ('Cannot specify @DataSetID.  @DataSetID is OUTPUT only.', 16, 1);
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
GRANT EXECUTE ON  [Batch].[ImportDataSet] TO [Processor]
GO
