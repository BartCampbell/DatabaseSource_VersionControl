SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [internal].[convert_value] (@origin_value [sql_variant], @data_type [nvarchar] (128))
RETURNS [sql_variant]
WITH EXECUTE AS CALLER
EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[ConvertValue]
GO
