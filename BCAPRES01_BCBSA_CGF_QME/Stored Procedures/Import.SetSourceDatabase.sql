SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/18/2011
-- Description:	Sets the database object pointers (as views or synonyms) to the specified database's objects.
-- =============================================
CREATE PROCEDURE [Import].[SetSourceDatabase]
(
	@DatabaseName nvarchar(128) = NULL,
	@TargetSchema nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	/*** USED TO GET THE LIST OF ORIGINAL SYNONYMS *****************************
	SELECT	QUOTENAME(s.name) + '.' + QUOTENAME(o.name) AS Syn, 
			o.name AS SynName, 
			s.name AS SynSchema 
	FROM	sys.objects AS o 
			INNER JOIN sys.schemas AS s 
					ON o.schema_id = s.schema_id 
	WHERE	(o.type = 'SN')
	ORDER BY Syn;
	***************************************************************************/

	IF @DatabaseName IS NULL
		SELECT TOP 1 @DatabaseName = SourceDatabase FROM Engine.Settings WHERE (EngineID = 1);

	IF @DatabaseName IS NOT NULL AND
		DB_ID(@DatabaseName) IS NOT NULL
		BEGIN;

			DECLARE @AsViews bit;
			SET @AsViews = 1; --Set to 1 due to changes made in Import.TransformProviders, utilizing COLUMNPROPERTY.

			WITH SourceObjectNames AS
			(
				SELECT CAST('[dbo].[Claim]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[ClaimLineItem]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Eligibility]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Employee]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[HealthPlan]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[LabResult]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Member]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[MemberProvider]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[MemberProviderMedicalGroup]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Network]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Pharmacy]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[PharmacyClaim]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Provider]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[ProviderAddress]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[ProviderMedicalGroup]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[QHPMemberInfo]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[Subscriber]' AS nvarchar(256)) AS ObjectName, 1 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[dbo].[prSetQiNetSyn]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 1 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Abstractor]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[EventAbstractors]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[EventDetail]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[HEDISSubMetric]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Measure]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[MeasureResults]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[MedicalRecordUpdates]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Member]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[MemberMeasureMetricScoring]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[MemberMeasureSample]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Provider]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[ProviderSite]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Pursuit]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[PursuitEvent]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[RefreshAll]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 1 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[SystematicSamples]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNet].[Settings]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[AdministrativeEvent]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[Member]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[MemberMeasureMetricScoring]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[MemberMeasureSample]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[Providers]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[ProviderSite]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[PursuitEvent]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[PursuitPriority]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
				UNION
				SELECT CAST('[ChartNetImport].[AdditionalMembers]' AS nvarchar(256)) AS ObjectName, 0 AS IsCritical, 0 AS IsRoutine
			)
			SELECT	CASE 
						WHEN @AsViews = 1 AND t.IsRoutine = 0
						THEN 'CREATE VIEW ' + T.ObjectName + ' AS SELECT * FROM ' + QUOTENAME(@DatabaseName) + '.' + T.ObjectName + ';'
						ELSE 'CREATE SYNONYM ' + T.ObjectName + ' FOR ' + QUOTENAME(@DatabaseName) + '.' + T.ObjectName + ';'
						END AS Cmd,
					IDENTITY(int, 1, 1) AS CmdID,
					CASE 
						WHEN OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.ObjectName) IS NOT NULL 
						THEN 
							CASE 
								WHEN OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.ObjectName), 'IsView') = 1 
								THEN 'DROP VIEW ' + T.ObjectName + ';'
								WHEN OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.ObjectName), 'IsExecuted') = 0 AND
										OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.ObjectName), 'IsTable') = 0 
								THEN 'DROP SYNONYM ' + T.ObjectName + ';'
								END 
						END AS DropCmd,
					t.IsCritical,
					CASE WHEN OBJECT_ID(QUOTENAME(@DatabaseName) + '.' + T.ObjectName) IS NOT NULL THEN 1 ELSE 0 END AS IsValidObject
			INTO	#Commands
			FROM	SourceObjectNames AS t;
    
			DECLARE @Cmd nvarchar(max);
			DECLARE @CmdID int;
			DECLARE @DropCmd nvarchar(max);
			DECLARE @IsCritical bit;
			DECLARE @IsValidObject bit;
			DECLARE @MaxCmdID int;
        
			SELECT @MaxCmdID = MAX(CmdID) FROM #Commands;
    
			WHILE (1 = 1)
				BEGIN;
					SET @CmdID = ISNULL(@CmdID, 0) + 1 
					IF @CmdID > @MaxCmdID
						BREAK;
	    
					SELECT	@Cmd = Cmd, 
							@DropCmd = DropCmd, 
							@IsCritical = IsCritical, 
							@IsValidObject = IsValidObject 
					FROM	#Commands 
					WHERE	(CmdID = @CmdID);
			
					IF @IsValidObject = 1
						BEGIN;
							IF NULLIF(LTRIM(@DropCmd), '') IS NOT NULL
								EXEC (@DropCmd);
						
							EXEC (@Cmd);
						END;
					ELSE IF @IsCritical = 1
						BEGIN
							DECLARE @ErrorMessage varchar(512);
							SET @ErrorMessage = 'Unable to create linking object, because the source object does not exist. Cannot execute: "' + @Cmd + '".';

							RAISERROR(@ErrorMessage, 16, 1);				
						END;
				END;
    
			IF @TargetSchema IS NOT NULL AND
				(
					(OBJECT_ID('[dbo].[prSetQiNetSyn]') IS NOT NULL) OR
					(EXISTS (SELECT TOP 1 1 FROM sys.synonyms AS s INNER JOIN sys.schemas AS c ON c.schema_id = s.schema_id WHERE s.name = 'prSetQiNetSyn' AND c.name = 'dbo'))
				)
				BEGIN;
					IF RIGHT(@TargetSchema, 1) <> '.'
						SET @TargetSchema = @TargetSchema + '.';

					DECLARE @SqlCmd nvarchar(max);
					SET @SqlCmd = 'EXEC [dbo].[prSetQiNetSyn] @vcSchema = ''' + @TargetSchema + ''';';
					EXEC (@SqlCmd);
				END;	
				
			UPDATE Engine.Settings SET SourceDatabase = @DatabaseName WHERE (EngineID = 1);	

			RETURN 0;
		END;
	ELSE
		RAISERROR ('Unable to set source.  The specified database is invalid.', 16, 1);
		RETURN 1;    
END
GO
GRANT EXECUTE ON  [Import].[SetSourceDatabase] TO [Processor]
GO
