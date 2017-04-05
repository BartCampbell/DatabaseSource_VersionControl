SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/21/2013
-- Description:	Determines if the specified database object or type exists.
-- =============================================
CREATE FUNCTION [DbUtility].[IsValidObject]
(
	@ObjectSchema nvarchar(128),
	@ObjectNane nvarchar(128)
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS (SELECT TOP 1 1 FROM sys.objects AS o INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id WHERE o.[name] = @ObjectNane AND s.[name] = @ObjectSchema) OR
		EXISTS (SELECT TOP 1 1 FROM sys.types AS t INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id WHERE t.[name] = @ObjectNane AND s.[name] = @ObjectSchema)
		SET @Result = 1;
	ELSE
		SET @Result = 0;
	
	RETURN @Result;
END
GO
GRANT EXECUTE ON  [DbUtility].[IsValidObject] TO [Processor]
GO
