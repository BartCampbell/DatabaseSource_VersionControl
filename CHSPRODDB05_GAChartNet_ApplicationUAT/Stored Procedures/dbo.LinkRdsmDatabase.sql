SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LinkRdsmDatabase]
(
	@TargetDatabase nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AppSchema nvarchar(128);
	DECLARE @RdsmSchema nvarchar(128);
	
	SET @AppSchema = 'RDSM';
	SET @RdsmSchema = 'dbo';

	DECLARE @Cmd nvarchar(max);
	DECLARE @CrLf nvarchar(max);
	
	SET @CrLf = CHAR(13) + CHAR(10);

	--Generate ALTER SYNONYM statements, as well as DROP statements if needed
	WITH SynObjects AS
	(
		SELECT 'AdministrativeEvent' AS ObjectName
		UNION
		SELECT 'ChartImageFileImport'
		UNION
		SELECT 'ImportChartImagesFromFTPS'
		UNION
		SELECT 'Member'
		UNION
		SELECT 'MemberMeasureMetricScoring'
		UNION
		SELECT 'MemberMeasureSample'
		UNION
		SELECT 'ProviderSite'
		UNION
		SELECT 'Providers'
		UNION
		SELECT 'PursuitEvent'
		UNION
		SELECT 'SupplementalMedicalRecordLocations'
		UNION 
		SELECT 'UpdateChartImagesXref'
    ),
    SynStatus AS
    (
		SELECT	SO.*,
				CASE WHEN S.[name] IS NOT NULL THEN 1 ELSE 0 END AS NeedsDrop,
				CASE WHEN object_id(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + SO.ObjectName) IS NOT NULL THEN 1 ELSE 0 END AS ObjectExists,
				object_id(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + SO.ObjectName) AS ObjectID
		FROM	SynObjects AS SO
				LEFT OUTER JOIN sys.synonyms AS S
						ON SO.ObjectName = S.name AND
							S.schema_id = schema_id(@AppSchema)
    )
    SELECT	@Cmd = ISNULL(@Cmd + @CrLf, '') + 
			CASE WHEN NeedsDrop = 1 
				 THEN 'DROP SYNONYM ' + QUOTENAME(@AppSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
				 ELSE '' 
				 END +
			CASE WHEN ObjectExists = 1 
				 THEN 'ALTER SYNONYM ' + QUOTENAME(@AppSchema) + '.' + QUOTENAME(ObjectName) + ' FOR ' + QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + QUOTENAME(ObjectName) + '; ' 
				 ELSE '' 
				 END
    FROM	SynStatus;
    
    --Clear empty statements...
    WHILE @@ROWCOUNT > 0
		SELECT @Cmd = REPLACE(@Cmd, REPLICATE(@CrLf, 2), @CrLf) FROM (SELECT 1 AS n) AS t WHERE CHARINDEX(REPLICATE(@CrLf, 2), @Cmd) > 0;
    
    --Print and execute statements...
    IF @Cmd IS NOT NULL
		BEGIN;
			PRINT @Cmd;
			EXEC (@Cmd);
		END;
    
END

GO
GRANT EXECUTE ON  [dbo].[LinkRdsmDatabase] TO [Support]
GO
