SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [internal].[get_server_account] (@account_name [internal].[adt_name] OUTPUT)
WITH EXECUTE AS CALLER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[GetServerAccount]
GO
GRANT EXECUTE ON  [internal].[get_server_account] TO [public]
GO
