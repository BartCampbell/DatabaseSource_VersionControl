SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/8/2015
-- Description:	Returns the description aggregate list associated with the specified BitSpecialties value.
-- =============================================
CREATE FUNCTION [Provider].[ConvertBitSpecialtiesToDescr]
(
	@value bigint
)
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @delimiter varchar(16);
	DECLARE @result varchar(1024);
	
	SET @delimiter = ' :: ';
	
	SELECT	@result = ISNULL(@result + @delimiter, '') + Descr
	FROM	Provider.Specialties AS PS WITH(NOLOCK)
	WHERE	(BitValue & @value > 0)
	ORDER BY Descr;
	
	IF @result IS NULL
		SET @result = '';

	RETURN @result;
END
GO
GRANT EXECUTE ON  [Provider].[ConvertBitSpecialtiesToDescr] TO [Processor]
GO
