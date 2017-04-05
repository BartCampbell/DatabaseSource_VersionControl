SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/26/2014
-- Description:	Returns the PriceCtgyCodeID associated with the specified GUID.
-- =============================================
CREATE FUNCTION [Ncqa].[RRU_ConvertPriceCtgyCodeIDFromGuid]
(
	@value varchar(36)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 PriceCtgyCodeID FROM Ncqa.RRU_PriceCategoryCodes WITH(NOLOCK) WHERE (PriceCtgyCodeGuid = CONVERT(uniqueidentifier, @value, 0)));
END
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyCodeIDFromGuid] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_ConvertPriceCtgyCodeIDFromGuid] TO [Submitter]
GO
