SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/28/2011
-- Description:	Returns the GUID associated with the specified PopulationID.
-- =============================================
CREATE FUNCTION [Member].[ConvertPopulationIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (CASE WHEN @value = 0
				THEN CONVERT(varchar(36), CONVERT(uniqueidentifier, CONVERT(binary(16), 0))) 
				ELSE (SELECT TOP 1 CONVERT(varchar(36), PopulationGuid) FROM Member.EnrollmentPopulations WITH(NOLOCK) WHERE (PopulationID = @value))
				END);
END

GO
GRANT EXECUTE ON  [Member].[ConvertPopulationIDToGuid] TO [Analyst]
GO
GRANT EXECUTE ON  [Member].[ConvertPopulationIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Member].[ConvertPopulationIDToGuid] TO [Submitter]
GO
