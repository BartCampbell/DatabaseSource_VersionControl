SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/13/2015
-- Description:	Enables/disables on or more indexes based on the specified critera.
-- =============================================
CREATE PROCEDURE [dbo].[ChangeIndexState]
(
	@DisplayMessages bit = 1,
	@IndexName nvarchar(128) = NULL,
	@IsEnabled bit,
	@TableName nvarchar(128),
	@TableSchema nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @IsEnabled IS NOT NULL
		BEGIN;
			DECLARE @IndexList table
            (
				ID int NOT NULL IDENTITY(1, 1),
				IndexName nvarchar(128) NOT NULL,
				IsDisabled bit NOT NULL,
				IsPrimary bit NOT NULL,
				IsUnique bit NOT NULL,
				IsUniqueConstraint bit NOT NULL,
				TableName nvarchar(128) NOT NULL,
				TableSchema nvarchar(128) NOT NULL,
				PRIMARY KEY CLUSTERED (ID ASC)
			);

			WITH IndexList AS
			(
				SELECT	i.name AS IndexName,
						i.is_disabled AS IsDisabled,
						i.is_primary_key AS IsPrimary,
						i.is_unique AS IsUnique,
						i.is_unique_constraint AS IsUniqueConstraint,
						o.name AS TableName,
						s.name AS TableSchema
				FROM	sys.indexes AS i 
						INNER JOIN sys.objects AS o 
								ON o.object_id = i.object_id
						INNER JOIN sys.schemas AS s
								ON s.schema_id = o.schema_id
				WHERE	o.type = 'U'
			)
			INSERT INTO @IndexList
			        (IndexName,
					IsDisabled,
					IsPrimary,
					IsUnique,
					IsUniqueConstraint,
					TableName,
					TableSchema)
			SELECT	IndexName,
					IsDisabled,
					IsPrimary,
					IsUnique,
					IsUniqueConstraint,
					TableName,
					TableSchema
			FROM	IndexList AS i
			WHERE	( --Index
						(
							(@IndexName IS NULL) AND 
							(i.IsPrimary = 0)
						) OR 
						(i.IndexName = @IndexName)
					) AND
					( --Enabled
						(i.IsDisabled = @IsEnabled)
					) AND
					( --Table
						(@TableName IS NULL) OR 
						(i.TableName = @TableName)
					) AND
					( --Schema
						(@TableSchema IS NULL) OR 
						(i.TableSchema = @TableSchema)
					);

			DECLARE @ID int, @MaxID int, @MinID int;
			SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @IndexList;

			DECLARE @SqlCmd nvarchar(MAX);
			DECLARE @SqlMsg nvarchar(MAX);

			WHILE (@ID BETWEEN @MinID AND @MaxID)
				BEGIN;
					SELECT	@SqlCmd = 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON ' + QUOTENAME(TableSchema) + '.' + QUOTENAME(TableName) + ' ' + 
										CASE @IsEnabled WHEN 1 THEN 'REBUILD' WHEN 0 THEN 'DISABLE' END + ';',
							@SqlMsg = CASE @IsEnabled WHEN 1 THEN 'Enabling/Rebuilding' WHEN 0 THEN 'Disabling' END + ' Index: ' + UPPER(QUOTENAME(IndexName)) + ' on ' + UPPER(QUOTENAME(TableSchema)) + '.' + UPPER(QUOTENAME(TableName)) + '...'
					FROM	@IndexList
					WHERE	(ID = @ID);

					IF @DisplayMessages = 1
						PRINT @SqlMsg;
					
					EXEC (@SqlCmd);

					IF @DisplayMessages = 1
						PRINT '...Done.' + REPLICATE(CHAR(13) + CHAR(10), 2);

					SET @ID = @ID + 1;
				END;

		END;
	ELSE
		RAISERROR('The parameter @IsEnabled cannot be NULL.', 16, 1);

END

GO
GRANT VIEW DEFINITION ON  [dbo].[ChangeIndexState] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[ChangeIndexState] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[ChangeIndexState] TO [Processor]
GO
