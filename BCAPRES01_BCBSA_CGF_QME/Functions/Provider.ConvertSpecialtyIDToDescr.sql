SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the description associated with the specified SpecialtyID.
-- =============================================
CREATE FUNCTION [Provider].[ConvertSpecialtyIDToDescr]
(
	@value smallint
)
RETURNS varchar(64)
AS
BEGIN
	RETURN (SELECT TOP 1 Descr FROM Provider.Specialties WITH(NOLOCK) WHERE (SpecialtyID = @value));
END


GO
GRANT EXECUTE ON  [Provider].[ConvertSpecialtyIDToDescr] TO [Analyst]
GO
GRANT EXECUTE ON  [Provider].[ConvertSpecialtyIDToDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Provider].[ConvertSpecialtyIDToDescr] TO [Submitter]
GO
