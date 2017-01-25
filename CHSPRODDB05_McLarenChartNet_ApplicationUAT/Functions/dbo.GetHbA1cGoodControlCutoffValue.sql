SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetHbA1cGoodControlCutoffValue]()
                    RETURNS INT
                    AS
                    BEGIN
                    DECLARE @Result INT
                    
                    --check for client override value
                    DECLARE @clientName VARCHAR(64)
                    SELECT @clientName = dbo.GetCurrentClient()
                    IF EXISTS (SELECT * FROM dbo.SystemParams WHERE ParamName = 'HbA1cGoodControlCutoff' AND ClientName = @clientName)
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'HbA1cGoodControlCutoff' AND ClientName = @clientName
					ELSE
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'HbA1cGoodControlCutoff' AND ClientName IS NULL 
                    RETURN @Result
                    END
                        
GO
