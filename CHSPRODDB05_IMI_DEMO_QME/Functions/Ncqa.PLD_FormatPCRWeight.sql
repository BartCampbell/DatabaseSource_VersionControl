SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/23/2012
-- Description:	Formats weight values for PCR to the specifications of the PLD, taking into account a few issues.
-- =============================================
CREATE FUNCTION [Ncqa].[PLD_FormatPCRWeight]
(
	@Weight decimal(18,10)
)
RETURNS varchar(12)
WITH SCHEMABINDING
AS
BEGIN
	--DECLARE @Result decimal(18,10);

	--IF @Weight > 9.9999999999
	--	SET @Result = 9.9999999999;
	--ELSE IF @Weight < -9.9999999999
	--	SET @Result = -9.9999999999;
	--ELSE
	--	SET @Result = @Weight;
		
	DECLARE @Result varchar(18);
	SET @Result = CONVERT(varchar(18), @Weight);		
		
	RETURN (CONVERT(varchar(12), LEFT(@Result, 12)));
END
GO
GRANT EXECUTE ON  [Ncqa].[PLD_FormatPCRWeight] TO [Processor]
GO
