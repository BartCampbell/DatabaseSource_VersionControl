SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/10/2015
-- Description:	Calculates the score based on denominator and numerator values
-- =============================================
CREATE FUNCTION [dbo].[Score]
(
	@IsDenominator bigint,
	@IsNumerator bigint
)
RETURNS decimal(18, 16)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE @Score decimal(32, 16);

	IF @IsDenominator > 0
		SET @Score = CONVERT(decimal(32, 16), @IsNumerator) / CONVERT(decimal(32, 16), @IsDenominator);
	ELSE
		SET @Score = 0;

	RETURN CONVERT(decimal(18, 16), @Score);
END
GO
GRANT EXECUTE ON  [dbo].[Score] TO [Processor]
GO
