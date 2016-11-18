SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[set_system_informations] (@operation_id [bigint])
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.SystemInformations].[SetSystemInformations]
GO
