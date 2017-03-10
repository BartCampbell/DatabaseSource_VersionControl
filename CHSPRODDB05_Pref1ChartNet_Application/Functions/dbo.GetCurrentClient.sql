SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetCurrentClient]() RETURNS VARCHAR(64) AS 
                    BEGIN
                    DECLARE @Result VARCHAR(64)
                    SELECT @Result = ParamCharValue FROM dbo.SystemParams WHERE ParamName = 'CurrentClient'
                    RETURN @Result
                    END
                        
GO
