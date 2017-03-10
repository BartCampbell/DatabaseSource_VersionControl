SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LinkFrameworkDatabase]
(
	@TargetDatabase nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AppSchema nvarchar(128);
	DECLARE @FrameworkSchema nvarchar(128);
	
	SET @AppSchema = 'Framework';
	SET @FrameworkSchema = 'dbo';

	DECLARE @Cmd nvarchar(max);
	DECLARE @CrLf nvarchar(max);
	
	SET @CrLf = CHAR(13) + CHAR(10);

	--Generate CREATE SYNONYM statements, as well as DROP statements if needed
	WITH SynObjects AS
	(
		SELECT	'PortalUser' AS ObjectName
		UNION
		SELECT	'PortalRole' AS ObjectName
		UNION
		SELECT	'PortalUserRole' AS ObjectName
    ),
    SynStatus AS
    (
		SELECT	SO.*,
				CASE WHEN S.[name] IS NOT NULL THEN 1 ELSE 0 END AS NeedsDrop,
				CASE WHEN object_id(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@FrameworkSchema) + '.' + SO.ObjectName) IS NOT NULL THEN 1 ELSE 0 END AS ObjectExists,
				object_id(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@FrameworkSchema) + '.' + SO.ObjectName) AS ObjectID
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
				 THEN 'CREATE SYNONYM ' + QUOTENAME(@AppSchema) + '.' + QUOTENAME(ObjectName) + ' FOR ' + QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@FrameworkSchema) + '.' + QUOTENAME(ObjectName) + '; ' 
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
GRANT EXECUTE ON  [dbo].[LinkFrameworkDatabase] TO [Support]
GO
