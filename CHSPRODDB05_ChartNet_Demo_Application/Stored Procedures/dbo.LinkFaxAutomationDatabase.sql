SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[LinkFaxAutomationDatabase]
(
	@TargetDatabase nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AppSchema nvarchar(128);
	DECLARE @RdsmSchema nvarchar(128);
	
	SET @AppSchema = 'FaxAutomation';
	SET @RdsmSchema = 'dbo';

	DECLARE @Cmd nvarchar(MAX);
	DECLARE @CrLf nvarchar(MAX);
	
	SET @CrLf = CHAR(13) + CHAR(10);

	--Generate CREATE SYNONYM statements, as well as DROP statements if needed
	WITH SynObjects AS
	(
		SELECT 'Faxes' AS ObjectName
		UNION
		SELECT 'FaxFileData'
		UNION
		SELECT 'FaxFiles'
    ),
    SynStatus AS
    (
		SELECT	SO.*,
				CASE WHEN S.[name] IS NOT NULL THEN 1 ELSE 0 END AS NeedsDrop,
				CASE WHEN OBJECT_ID(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + SO.ObjectName) IS NOT NULL THEN 1 ELSE 0 END AS ObjectExists,
				OBJECT_ID(QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + SO.ObjectName) AS ObjectID
		FROM	SynObjects AS SO
				LEFT OUTER JOIN sys.synonyms AS S
						ON SO.ObjectName = S.name AND
							S.schema_id = SCHEMA_ID(@AppSchema)
    )
    SELECT	@Cmd = ISNULL(@Cmd + @CrLf, '') + 
			CASE WHEN NeedsDrop = 1 
				 THEN 'DROP SYNONYM ' + QUOTENAME(@AppSchema) + '.' + QUOTENAME(ObjectName) + ';' + @CrLf
				 ELSE '' 
				 END +
			CASE WHEN ObjectExists = 1 
				 THEN 'CREATE SYNONYM ' + QUOTENAME(@AppSchema) + '.' + QUOTENAME(ObjectName) + ' FOR ' + QUOTENAME(@TargetDatabase) + '.' + QUOTENAME(@RdsmSchema) + '.' + QUOTENAME(ObjectName) + '; ' 
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
