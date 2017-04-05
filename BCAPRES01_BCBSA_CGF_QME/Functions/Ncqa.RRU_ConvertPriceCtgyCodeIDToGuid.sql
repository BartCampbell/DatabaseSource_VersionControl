SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the GUID associated with the specified PriceCtgyCodeGuid.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertPriceCtgyCodeIDToGuid]
(
	@value int
)
RETURNS varchar(36)
AS
BEGIN
	RETURN (SELECT TOP 1 CONVERT(varchar(36), PriceCtgyCodeGuid, 0) FROM Ncqa.RRU_PriceCategoryCodes WITH(NOLOCK) WHERE (PriceCtgyCodeID = @value));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyCodeIDToGuid] TO [Analyst]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyCodeIDToGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyCodeIDToGuid] TO [Submitter]
GO
