SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [internal].[get_isserver_processes] ()
RETURNS TABLE (
[process_id] [bigint] NULL)
WITH EXECUTE AS CALLER
EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.StartupApi].[GetISServerProcesses]
GO
