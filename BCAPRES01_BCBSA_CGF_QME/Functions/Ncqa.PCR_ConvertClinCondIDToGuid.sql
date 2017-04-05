SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/14/2012
-- Description:	Returns the GUID associated with the specified ClinCondID.
-- =============================================
CREATE FUNCTION [Ncqa].[PCR_ConvertClinCondIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(varchar(36), ClinCondGuid, 0) FROM Ncqa.PCR_ClinicalConditions WITH(NOLOCK) WHERE (ClinCondID = @value));
END


GO
GRANT EXECUTE ON  [Ncqa].[PCR_ConvertClinCondIDToGuid] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[PCR_ConvertClinCondIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[PCR_ConvertClinCondIDToGuid] TO [Submitter]
GO
