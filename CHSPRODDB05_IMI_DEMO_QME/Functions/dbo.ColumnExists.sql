SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/18/2011
-- Description:	Indicates whether or not the specified object has the specified column.
-- =============================================
CREATE FUNCTION [dbo].[ColumnExists]
(
	@ObjectName nvarchar(256),
	@ColumnName nvarchar(128)
)
RETURNS bit
AS
BEGIN

	RETURN (
				CASE WHEN 
						 EXISTS	(
									SELECT TOP 1 
											1
									FROM	INFORMATION_SCHEMA.COLUMNS 
									WHERE	(OBJECT_ID(QUOTENAME(TABLE_CATALOG) + '.' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)) = OBJECT_ID(@ObjectName)) AND
											(COLUMN_NAME = @ColumnName)
								)
					THEN 1
					ELSE 0
					END
			);

END
GO
GRANT EXECUTE ON  [dbo].[ColumnExists] TO [Processor]
GO
