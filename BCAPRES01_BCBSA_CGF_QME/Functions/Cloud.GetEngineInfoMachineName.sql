SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2013
-- Description:	Returns the machine name value from the supplied engine's info XML data.
-- =============================================
CREATE FUNCTION [Cloud].[GetEngineInfoMachineName]
(
	@Info xml
)
RETURNS nvarchar(512)
WITH SCHEMABINDING
AS
BEGIN
	
	RETURN (CASE WHEN @Info.exist('info[1]/category[@type=''System.Environment''][1]/item[@id=''MachineName''][1]/@value') = 1 THEN @Info.value('info[1]/category[@type=''System.Environment''][1]/item[@id=''MachineName''][1]/@value', 'nvarchar(512)') END);
	
END
GO
GRANT EXECUTE ON  [Cloud].[GetEngineInfoMachineName] TO [Processor]
GO
