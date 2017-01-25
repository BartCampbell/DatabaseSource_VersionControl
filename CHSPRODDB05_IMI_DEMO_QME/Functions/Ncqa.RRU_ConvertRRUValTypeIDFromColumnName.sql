SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the RRUValTypeID associated with the specified column name.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertRRUValTypeIDFromColumnName]
(
	@value varchar(128)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 RRUValTypeID FROM Ncqa.RRU_ValueTypes WITH(NOLOCK) WHERE (ColumnName = @value));
END

GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRRUValTypeIDFromColumnName] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertRRUValTypeIDFromColumnName] TO [Submitter]
GO
