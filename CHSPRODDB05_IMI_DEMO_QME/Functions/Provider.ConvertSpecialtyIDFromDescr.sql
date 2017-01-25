SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/10/2011
-- Description:	Returns the SpecialtyID associated with the specified description.
-- =============================================
CREATE FUNCTION [Provider].[ConvertSpecialtyIDFromDescr]
(
	@value varchar(64)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 SpecialtyID FROM Provider.Specialties WITH(NOLOCK) WHERE (Descr = @value));
END



GO
GRANT EXECUTE ON  [Provider].[ConvertSpecialtyIDFromDescr] TO [Processor]
GO
GRANT EXECUTE ON  [Provider].[ConvertSpecialtyIDFromDescr] TO [Submitter]
GO
