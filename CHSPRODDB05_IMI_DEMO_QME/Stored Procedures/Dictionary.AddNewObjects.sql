SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/30/2014
-- Description:	Adds new tables and columns to the data dictionary to be updated.
-- =============================================
CREATE PROCEDURE [Dictionary].[AddNewObjects]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BeginTranCount bigint;
	SET @BeginTranCount = @@TRANCOUNT;

	BEGIN TRY;

		BEGIN TRANSACTION TAddNewDictionaryObjects;

		INSERT INTO Dictionary.[Objects]
			(ObjectName,
			 ObjectSchema)
		SELECT	T.TABLE_NAME AS ObjectName,
				T.TABLE_SCHEMA AS ObjectSchema
		FROM	INFORMATION_SCHEMA.TABLES AS T
				LEFT OUTER JOIN Dictionary.[Objects] AS DO
						ON T.TABLE_NAME = DO.ObjectName AND
							T.TABLE_SCHEMA = DO.ObjectSchema              
		WHERE	(T.TABLE_TYPE = 'BASE TABLE') AND
				(DO.ObjectGuid IS NULL)
		ORDER BY 2, 1;
		
		INSERT INTO Dictionary.ObjectColumns
				(ColumnName,
				 ObjectName,
				 ObjectSchema)
		SELECT	C.COLUMN_NAME AS ColumnName,
				DO.ObjectName,
				DO.ObjectSchema
		FROM	INFORMATION_SCHEMA.COLUMNS AS C
				INNER JOIN Dictionary.[Objects] AS DO
						ON C.TABLE_NAME = DO.ObjectName AND
							C.TABLE_SCHEMA = DO.ObjectSchema
				LEFT OUTER JOIN Dictionary.ObjectColumns AS DOC
						ON DO.ObjectName = DOC.ObjectName AND 
							DO.ObjectSchema = DOC.ObjectSchema AND
							C.COLUMN_NAME = DOC.ColumnName
		WHERE	(DOC.ColumnName IS NULL)
		ORDER BY 3, 2, 1;

		COMMIT TRANSACTION TAddNewDictionaryObjects;

	END TRY
	BEGIN CATCH;  

		IF @@TRANCOUNT > @BeginTranCount
			ROLLBACK TRANSACTION TAddNewDictionaryObjects;

	END CATCH;

END
GO
GRANT EXECUTE ON  [Dictionary].[AddNewObjects] TO [Processor]
GO
