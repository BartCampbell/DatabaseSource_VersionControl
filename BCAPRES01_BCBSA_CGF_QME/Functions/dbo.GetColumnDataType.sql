SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/10/2011
-- Description:	Retrieves the data type of the specified column
-- =============================================
CREATE FUNCTION [dbo].[GetColumnDataType]
(
	@SchemaName nvarchar(128),
	@TableName nvarchar(128),
	@ColumnName nvarchar(128)
)
RETURNS nvarchar(128)
AS
BEGIN
	DECLARE @Result nvarchar(128)

	SELECT	@Result = DATA_TYPE
	FROM	INFORMATION_SCHEMA.COLUMNS
	WHERE	(TABLE_SCHEMA = @SchemaName) AND
			(TABLE_NAME = @TableName) AND
			(COLUMN_NAME = @ColumnName);

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [dbo].[GetColumnDataType] TO [Processor]
GO
