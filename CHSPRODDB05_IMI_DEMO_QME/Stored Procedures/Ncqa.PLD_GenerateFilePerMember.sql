SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/23/2012
-- Description:	Generates the "One Row Per Member"-style output file.
--				(File Processor: 0DE654C1-98F7-4CA5-82E3-DE22A0A9BA5D)
-- =============================================
CREATE PROCEDURE [Ncqa].[PLD_GenerateFilePerMember]
(
	@DataRunID int,
	@IsExactProductLine bit = 0,
	@OutputResultset bit = 0,
	@OutputFileContent bit = 1,
	@OutputSQL bit = 0,
	@OutputTempTables bit = 1,
	@PayerID int = NULL,
	@PldFileID int,
	@PopulationID int,
	@ProductLineID int,
	
	--Required to generate the PLD Header--
	@CmsContractNumber char(5),
	@NcqaSubmissionID char(5),
	@OrganizationName char(60)
)
AS
BEGIN;

	SET NOCOUNT ON;

	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;

	--Retrieve Data Run Info...
	SELECT	@DataSetID = DS.DataSetID,
			@MeasureSetID = DR.MeasureSetID 
	FROM	Batch.DataRuns AS DR
			INNER JOIN Batch.DataSets AS DS
					ON DR.DataSetID = DS.DataSetID
	WHERE	(DR.DataRunID = @DataRunID);

	--Retrieve the BitProductLines filter, if the product line filtering is "exact"...
	DECLARE @BitProductLines bigint;

	IF @IsExactProductLine = 1
		SELECT @BitProductLines = BitValue FROM Product.ProductLines WHERE ProductLineID = @ProductLineID;
	
	--Retrieve the PldFileProcessID associated with this procedure...
	DECLARE @PldFileProcessID int;
	SELECT	@PldFileProcessID = PldFileProcessID 
	FROM	Ncqa.PLD_FileProcessors 
	WHERE	(PldFileProcessGuid = '0DE654C1-98F7-4CA5-82E3-DE22A0A9BA5D');
	
	DECLARE @AllowLeadSpaces bit;
	SET @AllowLeadSpaces = 1;

	DECLARE @HasHeader bit;

	DECLARE @Aggregate nvarchar(16);
	DECLARE @DataType nvarchar(128);
	DECLARE @ColumnEnd smallint;
	DECLARE @ColumnLength smallint;
	DECLARE @ColumnPosition smallint;
	DECLARE @ColumnStart smallint;
	DECLARE @ConvertPrefix nvarchar(256);
	DECLARE @ConvertSuffix nvarchar(256);
	DECLARE @FieldDescr varchar(1024);
	DECLARE @FieldName nvarchar(128);
	DECLARE @FromAge tinyint;
	DECLARE @FromAgeTotMonths smallint;
	DECLARE @Gender tinyint;
	DECLARE @ValueIfNull nvarchar(64);
	DECLARE @IsHybrid bit;
	DECLARE @IsRightJustified bit;
	DECLARE @MeasureID int;
	DECLARE @MetricAbbrev varchar(16);
	DECLARE @MetricID int;
	DECLARE @ResultTypeID tinyint;
	DECLARE @SourceColumn nvarchar(128);
	DECLARE @SourceObject nvarchar(512);
	DECLARE @SourceSchema nvarchar(128);
	DECLARE @SourceTable nvarchar(128);
	DECLARE @ToAge tinyint;
	DECLARE @ToAgeTotMonths smallint;
	DECLARE @Validation nvarchar(512);
	DECLARE @WhereClause nvarchar(MAX);

	DECLARE @lf nvarchar(2);
	DECLARE @params nvarchar(MAX);
	DECLARE @sql nvarchar(MAX);
	DECLARE @tab nvarchar(1);

	SET @lf = CHAR(13) + CHAR(10);
	SET @tab = CHAR(9);

	BEGIN TRY;
		DECLARE @Message nvarchar(MAX);

		IF OBJECT_ID('tempdb..##PLD_MemberDetail') IS NOT NULL
			IF NOT EXISTS (SELECT TOP 1 1 FROM ##PLD_MemberDetail WHERE [SPID] <> @@SPID)
				DROP TABLE ##PLD_MemberDetail;
			ELSE
				BEGIN;

					SET @Message = 'The PLD process is already running under SPID ' + CAST((SELECT TOP 1 [SPID] FROM ##PL_MemberDetail WHERE [SPID] <> @@SPID) AS nvarchar(MAX)) + '.';
					
					RAISERROR (@Message, 16, 1);
				END;
			
		IF EXISTS (SELECT TOP 1 1 FROM Ncqa.PLD_FileLayouts WHERE (PldFileID = @PldFileID) AND ((PldColumnID IS NULL) OR (FieldName IS NULL)))
			BEGIN;
					SET @Message = 'Unable to generate the specified file.  One or more columns are not fully configured.';
					
					RAISERROR (@Message, 16, 1);
				END;

		SELECT @HasHeader = HasHeader FROM Ncqa.PLD_Files WHERE PldFileID = @PldFileID;

		--1) Store the layout specifications used for pulling the PLD file...			
		DECLARE @Layout TABLE
		(
			[Aggregate] varchar(128) NULL,
			ColumnEnd smallint NOT NULL,
			ColumnLength smallint NOT NULL,
			ColumnPosition smallint NOT NULL,
			ColumnStart smallint NOT NULL,
			ConvertPrefix nvarchar(256) NULL,
			ConvertSuffix nvarchar(256) NULL,
			DataType nvarchar(128) NOT NULL,
			FieldDescr varchar(1024) NOT NULL,
			FieldName nvarchar(128) NOT NULL,
			FromAge tinyint NULL,
			FromAgeTotMonths smallint NULL,
			Gender tinyint NULL,
			[ID] int IDENTITY(1,1) NOT NULL,
			IsRightJustified bit NOT NULL,
			MeasureID int NULL,
			MetricAbbrev varchar(16) NULL,
			MetricID int NULL,
			PldColumnID smallint NOT NULL,
			PldLayoutID int NOT NULL,
			ResultTypeID tinyint NULL,
			SourceColumn nvarchar(128) NOT NULL,
			SourceSchema nvarchar(128) NOT NULL,
			SourceTable nvarchar(128) NOT NULL,
			ToAge tinyint NULL,
			ToAgeTotMonths smallint NULL,
			[Validation] nvarchar(512) NULL,
			ValueIfNull nvarchar(64) NULL,
			WhereClause nvarchar(MAX) NULL
		);
						
		INSERT INTO @Layout
				([Aggregate],
				ColumnEnd,
				ColumnLength,
				ColumnPosition,
				ColumnStart,
				ConvertPrefix,
				ConvertSuffix,
				DataType,
				FieldDescr,
				FieldName,
				FromAge,
				FromAgeTotMonths,
				Gender,
				IsRightJustified,
				MeasureID,
				MetricAbbrev,
				MetricID,
				PldColumnID,
				PldLayoutID,
				ResultTypeID,
				SourceColumn,
				SourceSchema,
				SourceTable,
				ToAge,
				ToAgeTotMonths,
				[Validation],
				ValueIfNull,
				WhereClause)
		SELECT	NIA.Abbrev AS [Aggregate],
				NPL.ColumnEnd,
				NPL.ColumnLength,
				NPL.ColumnPosition,
				NPL.ColumnStart,
				NPC.ConvertPrefix,
				NPC.ConvertSuffix,
				NPC.DataType,
				NPL.FieldDescr,
				NPL.FieldName,
				NPL.FromAge,
				NPL.FromAgeTotMonths,
				NPL.Gender,
				NPC.IsRightJustified,
				NPL.MeasureID,
				NPL.MetricAbbrev,
				NPL.MetricID,
				NPL.PldColumnID,
				NPL.PldLayoutID,
				NIRT.ResultTypeID,
				NPC.SourceColumn,
				NPC.SourceSchema,
				NPC.SourceTable,
				NPL.ToAge,
				NPL.ToAgeTotMonths,
				NPV.Clause AS [Validation],
				NPC.ValueIfNull,
				NPC.WhereClause
		FROM	Ncqa.PLD_FileLayouts AS NPL
				INNER JOIN Ncqa.PLD_Files AS NPF
						ON NPL.PldFileID = NPF.PldFileID
				LEFT OUTER JOIN Ncqa.IDSS_Aggregates AS NIA
						ON NPL.AggregateID = NIA.AggregateID
				LEFT OUTER JOIN Ncqa.PLD_Columns AS NPC
						ON NPL.PldColumnID = NPC.PldColumnID
				LEFT OUTER JOIN Ncqa.PLD_Validations AS NPV
						ON NPL.ValidateID = NPV.ValidateID
				OUTER APPLY (
								--Switched to OUTER APPLY from LEFT OUTER JOIN due to duplication caused by multiple systematic samples for a given population/product line combination (like Evolent, HEDIS 2016)
								SELECT TOP 1
										tNIRT.*
								FROM	Ncqa.IDSS_ResultType AS tNIRT
								WHERE	tNIRT.MeasureID = NPL.MeasureID AND
										tNIRT.DataRunID = @DataRunID AND
										tNIRT.DataSetID = @DataSetID AND
										(@PayerID IS NULL OR tNIRT.PayerID = @PayerID) AND
										tNIRT.PopulationID = @PopulationID AND
										tNIRT.ProductLineID = @ProductLineID
								ORDER BY tNIRT.HasAllPayers DESC, 
										tNIRT.ResultTypeID DESC
							) AS NIRT
		WHERE	(NPF.PldFileID = @PldFileID)  AND
				(NPF.PldFileProcessID = @PldFileProcessID) AND
				(NPF.MeasureSetID = @MeasureSetID)
		ORDER BY ColumnPosition;
		
		--IF @OutputResultSet = 1
		--	SELECT * FROM @Layout;
		
		IF @@ROWCOUNT > 0
			BEGIN;
		
				DECLARE @ID int;
				DECLARE @MaxID int;
				DECLARE @MinID int;
				
				SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @Layout;
				
				--2) Create the table ##PLD_MemberDetail for storing the PLD file contents...
				--2a) Initialize the script used to create the PLD layout
				SET @sql = 'CREATE TABLE ##PLD_MemberDetail' + @lf +
							'(' + @lf +
							@tab + '[DataRunID] int NOT NULL,' + @lf +
							@tab + '[DSMemberID] bigint NOT NULL,' + @lf +
							@tab + '[IhdsMemberID] int NOT NULL,' + @lf +
							@tab + '[SPID] int NOT NULL'

				--2b) Loop through the columns to set the fields in the CREATE TABLE script
				SELECT	@sql = ISNULL(@sql + ', ' + @lf + @tab, '') + QUOTENAME(FieldName) + ' char(' + CAST(ColumnLength AS nvarchar(MAX)) + ') NULL'
				FROM	@Layout
				ORDER BY [ID];
				
				SET @sql = @sql + @lf + ')';
				
				--2c) PRINT the script and EXECUTE the creation of ##PLD_MeasureDetail
				IF @OutputSql = 1 			
					PRINT @sql;
					
				EXEC (@sql);
				
				--3) Populate the ##PLD_MeasureDetail with data from dynamically-constructed SQL statements...
				--3a) Populate the base columns of ##PLD_MeasureDetail
				INSERT INTO ##PLD_MemberDetail
						(DataRunID, DSMemberID, IhdsMemberID, SPID)
				SELECT 	DataRunID, DSMemberID, IhdsMemberID, @@SPID
				FROM	Ncqa.PLD_MemberInfo
				WHERE	--(CountMonths > 0) AND
						(DataRunID = @DataRunID) AND
						(PopulationID = @PopulationID) AND
						(ProductLineID = @ProductLineID);
				
				CREATE UNIQUE CLUSTERED INDEX IX_##PLD_MemberDetail ON ##PLD_MemberDetail (DSMemberID);

				SET @ID = @MinID;
				SET @sql = NULL;
				
				--3b) Loop through each column of ##PLD_MemberDetail, populating the entire column for each member in one statement
				WHILE (@ID BETWEEN @MinID AND @MaxID)
					BEGIN
						--Pull in the layout instructions as variables
						SELECT  @Aggregate = t.[Aggregate],
								@ColumnEnd = t.ColumnEnd,
								@ColumnLength = t.ColumnLength,
								@ColumnPosition = t.ColumnPosition,
								@ColumnStart = t.ColumnStart,
								@ConvertPrefix = t.ConvertPrefix,
								@ConvertSuffix = t.ConvertSuffix,
								@DataType = t.DataType,
								@FieldDescr = t.FieldDescr,
								@FieldName = t.FieldName,
								@FromAge = t.FromAge,
								@FromAgeTotMonths = t.FromAgeTotMonths,
								@Gender = t.Gender,
								@IsHybrid = ISNULL(MM.IsHybrid, 0),
								@IsRightJustified = t.IsRightJustified,
								@MeasureID = t.MeasureID,
								@MetricAbbrev = t.MetricAbbrev,
								@MetricID = t.MetricID,
								@ResultTypeID = t.ResultTypeID,
								@SourceColumn = t.SourceColumn,
								@SourceObject = DB_NAME() + '.' + QUOTENAME(t.SourceSchema) + '.' + QUOTENAME(t.SourceTable),
								@SourceSchema = t.SourceSchema,
								@SourceTable = t.SourceTable,
								@ToAge =t. ToAge,
								@ToAgeTotMonths = t.ToAgeTotMonths,
								@Validation = t.[Validation],
								@ValueIfNull = t.ValueIfNull,
								@WhereClause = t.WhereClause
						FROM	@Layout AS t
								LEFT OUTER JOIN Measure.Measures AS MM
										ON MM.MeasureID = t.MeasureID
						WHERE	(t.ID = @ID);
						
						--Buid the SQL script to execute
						IF (@SourceObject IS NOT NULL)
							BEGIN
								SET @sql =	'WITH [Results] AS ' + @lf +
											'(' + @lf + @tab +
											'SELECT	' +
														CASE WHEN @IsRightJustified = 1 AND @AllowLeadSpaces = 1 THEN
																'dbo.LeadSpaces('
															ELSE
																''
															END + 
														'ISNULL(CAST(' + UPPER(@Aggregate) + '(' + 
														ISNULL(@ConvertPrefix, '') + 
														CASE WHEN @DataType IS NOT NULL 
															THEN 'CAST(x.' + QUOTENAME(@SourceColumn) + ' AS ' + @DataType + ')' 
															ELSE 'x.' + QUOTENAME(@SourceColumn) 
															END + 
														ISNULL(@ConvertSuffix, '') +
														') AS char(' + CAST(@ColumnLength AS nvarchar(MAX)) + ')), ' +  
														CASE WHEN @ValueIfNull IS NOT NULL AND
																 LEFT(@ValueIfNull, 1) = '@' 
															THEN @ValueIfNull
															ELSE '''' + ISNULL(@ValueIfNull, '') + ''''
															END  + ') ' +
														CASE WHEN @IsRightJustified = 1 AND @AllowLeadSpaces = 1 THEN
																', ' + CAST(@ColumnLength AS nvarchar(MAX)) + ')'
															ELSE
																''
															END + 
														' AS ' + QUOTENAME(@FieldName) + ', ' + @lf + @tab +
											'		t.DSMemberID, t.IhdsMemberID, t.DataRunID' + @lf + @tab +
											'FROM	##PLD_MemberDetail AS t' + @lf +  @tab +
											'		LEFT OUTER JOIN ' + @SourceObject + ' AS x' + @lf +@tab +
											'				ON /***DYNAMIC JOIN COLUMNS********************/' + @lf + @tab +
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'DSMemberID', 'ColumnId') IS NOT NULL 
												THEN '					t.DSMemberID = x.DSMemberID AND' + @lf  + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'IhdsMemberID', 'ColumnId') IS NOT NULL 
												THEN '					t.IhdsMemberID = x.IhdsMemberID AND ' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'ihds_member_id', 'ColumnId') IS NOT NULL 
												THEN '					t.IhdsMemberID = x.ihds_member_id AND ' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'AgeMonths', 'ColumnId') IS NOT NULL 
												THEN '					x.AgeMonths BETWEEN ISNULL(@FromAgeTotMonths, x.AgeMonths) AND ISNULL(@ToAgeTotMonths, x.AgeMonths) AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'AgeMonths', 'ColumnId') IS NULL AND
													  COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'Age', 'ColumnId') IS NOT NULL 
												THEN '					x.Age BETWEEN ISNULL(@FromAge, x.Age) AND ISNULL(@ToAge, x.Age) AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'DataRunID', 'ColumnId') IS NOT NULL 
												THEN '					x.DataRunID = @DataRunID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'DataSetID', 'ColumnId') IS NOT NULL 
												THEN '					x.DataSetID = @DataSetID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'Gender', 'ColumnId') IS NOT NULL AND @Gender IS NOT NULL
												THEN '					x.Gender = @Gender AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'MeasureID', 'ColumnId') IS NOT NULL AND @MeasureID IS NOT NULL
												THEN '					x.MeasureID = @MeasureID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'MetricID', 'ColumnId') IS NOT NULL AND @MetricID IS NOT NULL
												THEN '					x.MetricID = @MetricID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'PayerID', 'ColumnId') IS NOT NULL AND @PayerID IS NOT NULL
												THEN '					x.PayerID = @PayerID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'PopulationID', 'ColumnId') IS NOT NULL 
												THEN '					x.PopulationID = @PopulationID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'ProductLineID', 'ColumnId') IS NOT NULL 
												THEN '					x.ProductLineID = @ProductLineID AND' + @lf + @tab
												ELSE '' END + 
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'BitProductLines', 'ColumnId') IS NOT NULL AND @BitProductLines IS NOT NULL AND @IsHybrid = 1 --For hybrid measures only
												THEN '					x.BitProductLines = @BitProductLines AND' + @lf + @tab --Must be Equals, NOT a normal bitwise comparison!
												ELSE '' END +
											CASE WHEN COLUMNPROPERTY(OBJECT_ID(@SourceObject), 'ResultTypeID', 'ColumnId') IS NOT NULL AND @ResultTypeID IS NOT NULL
												THEN '					x.ResultTypeID IN (@ResultTypeID, 4) AND' + @lf + @tab
												ELSE '' END +
											ISNULL('					x.' + @WhereClause + ' AND' + @lf + @tab, '') + 
											'					1 = 1' + @lf + @tab + --Dummy Line.  DO NOT REMOVE.  It makes the ANDs work in all cases.
											'WHERE	(t.DataRunID = @DataRunID)' + @lf + @tab +
											'GROUP BY t.DSMemberID, t.IhdsMemberID, t.DataRunID' + @lf +
											')' + @lf +
											'UPDATE	t' + @lf +
											'SET	' + @tab + QUOTENAME(@FieldName) + ' = R.' + QUOTENAME(@FieldName) + @lf +
											'FROM	##PLD_MemberDetail AS t' + @lf +
											'		INNER JOIN [Results] AS R' + @lf +
											'				ON t.DataRunID = R.DataRunID AND' + @lf +
											'					t.DSMemberID = R.DSMemberID AND' + @lf +
											'					t.IhdsMemberID = R.IhdsMemberID'
							END;	

						IF @OutputSql = 1 			
							BEGIN;
								PRINT '';
								PRINT '';
								PRINT '**********************************************************************';
								PRINT 'Column Number:';
								PRINT @ColumnPosition;
								PRINT '';
								PRINT 'SQL Statement:';
								PRINT @sql;
								PRINT '';
							END;

						--Execute the generated SQL script
						SET @params = '@BitProductLines bigint, @DataRunID int, @DataSetID int, @FromAge tinyint, @FromAgeTotMonths smallint, @Gender tinyint, @MeasureID int, @MeasureSetID int, ' +
										'@MetricAbbrev varchar(16), @MetricID int, @NcqaSubmissionID char(5), @PayerID int, @PopulationID int, ' +
										'@ProductLineID int, @ResultTypeID tinyint, @ToAge tinyint, @ToAgeTotMonths smallint';

						EXEC sys.sp_executesql @statement = @sql, @params = @params, 
												@BitProductLines = @BitProductLines, @DataRunID = @DataRunID, @DataSetID = @DataSetID, @FromAge = @FromAge, @FromAgeTotMonths = @FromAgeTotMonths, @Gender = @Gender, @MeasureID = @MeasureID, @MeasureSetID = @MeasureSetID,
												@MetricAbbrev = @MetricAbbrev, @MetricID = @MetricID, @NcqaSubmissionID = @NcqaSubmissionID, @PayerID = @PayerID, @PopulationID = @PopulationID, 
												@ProductLineID = @ProductLineID, @ResultTypeID = @ResultTypeID, @ToAge = @ToAge, @ToAgeTotMonths = @ToAgeTotMonths;
									
						IF @OutputSql = 1 			
							BEGIN;	
								PRINT '';
								PRINT '';
							END;
						
						SET @ID = ISNULL(@ID, 0) + 1;
					END;

				--3c) Validate the values of ##PLD_MemberDetail
				SET @sql = NULL;
				
				SELECT	@sql = ISNULL(@sql + @lf + @tab + 'UNION ALL' + @lf + @tab, '') + 
								'SELECT' + @tab + 'DSMemberID, ColumnPosition, FieldName, [Value], CASE WHEN ' + [Validation] + ' THEN 1 ELSE 0 END AS IsValid ' + @lf + @tab +
								'FROM ' + @tab +
								'(SELECT DSMemberID, ' + CONVERT(nvarchar(16), ColumnPosition) + ' AS ColumnPosition, ''' + FieldName + ''' AS FieldName, ' + 
								QUOTENAME(FieldName) + ' AS [Value] FROM ##PLD_MemberDetail) AS t'
				FROM	@Layout
				ORDER BY [ID];
				
				DECLARE @Invalid TABLE
				(
					DSMemberID bigint NOT NULL,
					ColumnPosition smallint NOT NULL,
					FieldName nvarchar(128) NOT NULL,
					Value varchar(512) NOT NULL,
					IsValid bit NOT NULL
				);
				
				SET @sql = 'WITH ValidationSource AS ' + @lf + '(' + @lf + @tab + @sql + ')' + @lf + ' SELECT * FROM ValidationSource WHERE (IsValid = 0)';
				
				IF @OutputSql = 1 			
					PRINT @sql;
				
				INSERT INTO @Invalid
					EXEC (@sql);
				
				IF @@ROWCOUNT > 0 
					BEGIN;
						SELECT	RDSMK.CustomerMemberID AS [Member ID],
								RDSMK.DisplayID AS [IMI Member ID],
								RDSMK.NameLast AS [Last Name],
								RDSMK.NameFirst AS [First Name],
								RDSMK.DOB AS [Date of Birth],
								RDSMK.Gender,
								t.DSMemberID AS [Member Ref ID],
                                t.ColumnPosition AS [Column],
                                t.FieldName AS [Field Name],
                                t.Value,
                                --t.IsValid, 
								l.[Validation] 
						FROM	@Invalid AS t 
								INNER JOIN @Layout AS l 
										ON t.FieldName = l.FieldName AND 
											l.ColumnPosition = t.ColumnPosition
								INNER JOIN Result.DataSetMemberKey AS RDSMK
										ON RDSMK.DSMemberID = t.DSMemberID AND
											RDSMK.DataRunID = @DataRunID;
						RAISERROR('One or more entries did not pass validation.  Please review the resultset for more information.', 16, 1);
					END;
					
				--3d) Returns the fully populated ##PLD_MemberDetail table
				IF @OutputResultset = 1
					SELECT * FROM ##PLD_MemberDetail;
					
				--4) Generate the results to copy/paste into the final text file...
				--4a) Loop through the layout to list the columns of the file
				SET @sql = NULL;
				
				SELECT	@sql = ISNULL(@sql + ' + ', '') + QUOTENAME(FieldName)
				FROM	@Layout
				ORDER BY [ID];

				IF @OutputFileContent = 1
					BEGIN;
						--4b) Add the file header to the script and execute the script to pull the file's full contents
						SET @sql = 'SELECT ' + @sql + ' AS [PLD FileContent] FROM ##PLD_MemberDetail;';

						IF @HasHeader = 1
						SET @sql = 'SELECT CAST(''~' + @CmsContractNumber + @OrganizationName + @NcqaSubmissionID + ''' AS char(' + 
									CAST((SELECT MAX(ColumnEnd) FROM Ncqa.PLD_FileLayouts WHERE PldFileID = @PldFileID) AS varchar) + 
									')) AS [PLD FileContent]' + @lf + 'UNION ALL' + @lf + @sql;
						
						IF @OutputSql = 1 			
							PRINT @sql;
							
						EXEC (@sql);
						
						--4c) Return the maximum length of the "FileContent" field for reconciliation purposes
						SET @sql = 'SELECT LEN(REPLACE(t.[PLD FileContent], '' '', ''*'')) AS FileContentLength, COUNT(*) AS CountRecords FROM (' + REPLACE(@sql, ';', '') + ') AS t GROUP BY LEN(REPLACE(t.[PLD FileContent], '' '', ''*''))';
						
						IF @OutputSql = 1 			
							PRINT @sql;
							
						EXEC (@sql);

						--4d) Output the file to a table in the "Temp" schema for archiving...
						IF @OutputTempTables = 1
							BEGIN;
								DECLARE @TableName nvarchar(128);
								SET @TableName = 'PLD_' + CONVERT(nvarchar(128), GETDATE(), 112) + '_' + REPLACE(CONVERT(nvarchar(128), GETDATE(), 114), ':', '') + '_' + REPLACE(CONVERT(nvarchar(128), NEWID()), '-', '');
								PRINT '';
								PRINT @TableName;
								PRINT '';

								SET @sql = NULL;
								SELECT	@sql = ISNULL(@sql + ' + ', '') + QUOTENAME(FieldName)
								FROM	@Layout
								ORDER BY [ID];

								IF @HasHeader = 1
									SET @sql = 'SELECT ' + @sql + ' AS [PLD FileContent] FROM ##PLD_MemberDetail;';
								ELSE
									SET @sql = 'SELECT ' + @sql + ' AS [PLD FileContent] INTO [Temp].' + QUOTENAME(@TableName + '_Export') + ' FROM ##PLD_MemberDetail;';
						
								IF @HasHeader = 1
								SET @sql = 'SELECT CAST(''~' + @CmsContractNumber + @OrganizationName + @NcqaSubmissionID + ''' AS char(' + 
											CAST((SELECT MAX(ColumnEnd) FROM Ncqa.PLD_FileLayouts WHERE PldFileID = @PldFileID) AS varchar) + 
											')) AS [PLD FileContent] ' + @lf + 'INTO [Temp].' + QUOTENAME(@TableName + '_Export') + @lf + 'UNION ALL' + @lf + @sql;
						
								IF @OutputSql = 1 			
									PRINT @sql;
							
								EXEC (@sql);

								IF @OutputResultset = 1
									BEGIN;
										SET @sql = 'SELECT * INTO [Temp].' + QUOTENAME(@TableName + '_Detail') + ' FROM ##PLD_MemberDetail;'
						
										IF @OutputSql = 1 			
											PRINT @sql;
							
										EXEC (@sql);
									END;
							END;
					END;
			END;

			IF OBJECT_ID('tempdb..##PLD_MemberDetail') IS NOT NULL
				DROP TABLE ##PLD_MemberDetail;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrorLine int;
		DECLARE @ErrorMessage nvarchar(MAX);
		
		SET @ErrorLine =  ERROR_LINE();
		SET @ErrorMessage = ERROR_MESSAGE();
		
		SET @ErrorMessage = @ErrorMessage + ' (Line: ' + CAST(@ErrorLine AS nvarchar(MAX)) + ')';
		
		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH;

END;

GO
GO
GRANT VIEW DEFINITION ON  [Ncqa].[PLD_GenerateFilePerMember] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_GenerateFilePerMember] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_GenerateFilePerMember] TO [Processor]
GO
GO

GO
