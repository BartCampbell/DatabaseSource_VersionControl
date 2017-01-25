SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/31/2012
-- Description:	Retrieves the unique identifier for the current instance of the engine.
-- =============================================
CREATE FUNCTION [Engine].[GetEngineGuid]
(
)
RETURNS uniqueidentifier
AS
BEGIN
	
	DECLARE @Result uniqueidentifier;
	
	SELECT	@Result = EngineGuid
	FROM	Engine.Settings
	WHERE	(EngineID = 1);
	
	RETURN @Result;

END
GO
GRANT EXECUTE ON  [Engine].[GetEngineGuid] TO [Processor]
GO
