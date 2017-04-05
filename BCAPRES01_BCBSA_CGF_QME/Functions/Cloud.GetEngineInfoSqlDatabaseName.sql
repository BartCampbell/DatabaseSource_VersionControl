SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2013
-- Description:	Returns the SQL Server database name value from the supplied engine's info XML data.
-- =============================================
CREATE FUNCTION [Cloud].[GetEngineInfoSqlDatabaseName]
(
	@Info xml
)
RETURNS nvarchar(512)
WITH SCHEMABINDING
AS
BEGIN
	
	RETURN (CASE WHEN @Info.exist('info[1]/category[@type=''IMI.MeasureEngine.Data.IMeasureEngineComponentDataSource''][1]/item[@id=''DatabaseName''][1]/@value') = 1 THEN @Info.value('info[1]/category[@type=''IMI.MeasureEngine.Data.IMeasureEngineComponentDataSource''][1]/item[@id=''DatabaseName''][1]/@value', 'nvarchar(512)') END);
	
END
GO
GRANT EXECUTE ON  [Cloud].[GetEngineInfoSqlDatabaseName] TO [Processor]
GO
