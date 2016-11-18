SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[stop_operation_internal] (@operation_id [bigint], @process_id [int], @operation_guid [uniqueidentifier])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[StopOperationInternal]
GO
