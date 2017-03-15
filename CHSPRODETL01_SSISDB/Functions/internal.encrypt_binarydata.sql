SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [internal].[encrypt_binarydata] (@algorithmName [nvarchar] (255), @key [varbinary] (8000), @IV [varbinary] (8000), @binary_value [varbinary] (max))
RETURNS [varbinary] (max)
WITH EXECUTE AS CALLER
EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.Security.CryptoGraphy].[EncryptBinaryData]
GO
