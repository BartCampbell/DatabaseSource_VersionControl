SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/28/2011
-- Description:	Returns the PopulationID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Member].[ConvertPopulationIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (CASE WHEN @value = CONVERT(varchar(36), CONVERT(uniqueidentifier, CONVERT(binary(16), 0))) 
				THEN 0
				ELSE (SELECT TOP 1 PopulationID FROM Member.EnrollmentPopulations WITH(NOLOCK) WHERE (PopulationGuid = CONVERT(uniqueidentifier, @value)))
				END);
END

GO
GRANT EXECUTE ON  [Member].[ConvertPopulationIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertPopulationIDFromGuid] TO [Submitter]
GO
