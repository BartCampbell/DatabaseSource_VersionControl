SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/10/2015
-- Description:	Returns the lower confidence interval per NCQA's guidelines.  
-- =============================================
CREATE FUNCTION [Ncqa].[LowerConfidenceInterval] 
(
	@IsDenominator bigint,
	@IsNumerator bigint
)
RETURNS decimal(18, 16)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @Result decimal(32, 16);
	
	IF @IsDenominator > 0
		BEGIN;
			DECLARE @Score decimal(32, 16);
			SET @Score = CONVERT(decimal(32, 16), @IsNumerator) / CONVERT(decimal(32, 16), @IsDenominator);

			SET @Result =	@Score - 
							(
								CONVERT(decimal(32, 16), 1.96) * 
								SQRT(
										(
											@Score * 
											(
												CONVERT(decimal(32, 16), 1) - 
												@Score
											)
										) / 
										CONVERT(decimal(32, 16), @IsDenominator)
									)
							) - 
							(
								CONVERT(decimal(32, 16), 1) / CONVERT(decimal(32, 16), 2 * @IsDenominator)
							);

			IF @Result < 0 
				SET @Result = 0;
		END;
	ELSE
		SET @Result = 0;

	RETURN CONVERT(decimal(18, 16), @Result);

END
GO
GRANT EXECUTE ON  [Ncqa].[LowerConfidenceInterval] TO [Processor]
GO
GRANT EXECUTE ON  [Ncqa].[LowerConfidenceInterval] TO [Reporting.Analysts]
GO
GRANT EXECUTE ON  [Ncqa].[LowerConfidenceInterval] TO [Reporting.Analysts.Readonly]
GO
