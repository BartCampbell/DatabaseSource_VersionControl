SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2012
-- Description:	Returns the description associated with the specified MapTypeID.
-- =============================================
CREATE FUNCTION [Claim].[ConvertMapTypeIDToDescr]
(
	@value tinyint
)
RETURNS varchar(64)
AS
BEGIN
	RETURN (SELECT TOP 1 Descr FROM Measure.MappingTypes WITH(NOLOCK) WHERE (MapTypeID = @value));
END

GO
GRANT EXECUTE ON  [Claim].[ConvertMapTypeIDToDescr] TO [Processor]
GO
