SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/25/2011
-- Description:	Returns a value indicating whether or not the specified parameter belongs to the specified procedure
-- =============================================
CREATE FUNCTION [Batch].[HasProcedureParameter]
(
	@ProcedureSchema nvarchar(128),
	@ProcedureName nvarchar(128),
	@ParameterName nvarchar(128)
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS(
				SELECT	1 
				FROM	INFORMATION_SCHEMA.PARAMETERS AS t 
				WHERE	t.SPECIFIC_SCHEMA = @ProcedureSchema AND	
						t.SPECIFIC_NAME = @ProcedureName AND
						t.PARAMETER_NAME = @ParameterName 
			 )
		SET @Result = 1;
	ELSE
		SET @Result = 0;
	
	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Batch].[HasProcedureParameter] TO [Processor]
GO
