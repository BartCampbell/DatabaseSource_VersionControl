SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[create_execution_dump_internal] (@execution_id [bigint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[CreateExecutionDumpInternal]
GO
