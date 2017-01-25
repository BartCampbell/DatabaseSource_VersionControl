SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the column name associated with the specified Value Types.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertRRUValTypeIDToColumnName]
(
	@value tinyint
)
RETURNS varchar(128)
AS
BEGIN
	RETURN (SELECT TOP 1 ColumnName FROM Ncqa.RRU_ValueTypes WITH(NOLOCK) WHERE (RRUValTypeID = @value));
END

GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRRUValTypeIDToColumnName] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRRUValTypeIDToColumnName] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRRUValTypeIDToColumnName] TO [Submitter]
GO
