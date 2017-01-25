SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2012
-- Description:	Returns the MapTypeID associated with the specified description.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMapTypeIDFromDescr]
(
	@value varchar(64)
)
RETURNS tinyint 
AS
BEGIN
	RETURN (SELECT TOP 1 MapTypeID FROM Measure.MappingTypes WITH(NOLOCK) WHERE (Descr = @value));
END

GO
GRANT EXECUTE ON  [Measure].[ConvertMapTypeIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMapTypeIDFromDescr] TO [Submitter]
GO
