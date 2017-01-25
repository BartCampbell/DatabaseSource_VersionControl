SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/6/2012
-- Description:	Returns a list of columns associated with the specified index.
-- =============================================
CREATE FUNCTION [dbo].[GetIndexColumns]
(
	@object_id int,
	@index_id int,
	@show_includes bit = 0,
	@show_sorts bit = 0
)
RETURNS nvarchar(max)
AS
BEGIN
	
	DECLARE @columns nvarchar(max);

	SELECT	@columns =	ISNULL(@columns + ', ', '') + c.name + 
						CASE 
							WHEN @show_sorts = 1 AND ic.is_included_column = 0 AND ic.is_descending_key = 0 
							THEN ' ASC' 
							WHEN @show_sorts = 1 AND ic.is_included_column = 0 AND ic.is_descending_key = 1 
							THEN ' DESC' 
							ELSE '' END
	FROM	sys.index_columns AS ic
			INNER JOIN sys.columns AS c
					ON ic.column_id = c.column_id AND
						ic.object_id = c.object_id
	WHERE	ic.object_id = @object_id AND
			ic.index_id = @index_id AND
			ic.is_included_column = @show_includes
	ORDER BY ic.index_column_id;

	RETURN @columns;
END
GO
GRANT EXECUTE ON  [dbo].[GetIndexColumns] TO [Processor]
GO
