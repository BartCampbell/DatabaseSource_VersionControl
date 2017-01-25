SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/2/2011
-- Description:	Indicates whether or not the specified benefit has child benefits.
-- =============================================
CREATE FUNCTION [Product].[IsParentBenefit]
(
	@BenefitID smallint
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	SELECT @Result = CONVERT(bit, CASE WHEN EXISTS(SELECT TOP 1 1 FROM [Product].[BenefitRelationships] AS t WHERE [t].[BenefitID] = @BenefitID) THEN 1 ELSE 0 END);
	
	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Product].[IsParentBenefit] TO [Processor]
GO
