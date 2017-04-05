SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2012
-- Description:	Returns the ClinCond associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Ncqa].[PCR_ConvertClinCondIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 ClinCondID FROM Ncqa.PCR_ClinicalConditions WITH(NOLOCK) WHERE (ClinCondGuid = CONVERT(uniqueidentifier, @value, 0)));
END


GO
GRANT EXECUTE ON  [Ncqa].[PCR_ConvertClinCondIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[PCR_ConvertClinCondIDFromGuid] TO [Submitter]
GO
