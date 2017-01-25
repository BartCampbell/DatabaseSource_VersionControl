SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetRiskYear]()
                    RETURNS smallint
                    AS
                    BEGIN
                    DECLARE @Result smallint
                    
                    --check for client override value
                    DECLARE @clientName varchar(64)
                    SELECT @clientName = dbo.GetCurrentClient()
                    
                    IF EXISTS (SELECT * FROM dbo.SystemParams WHERE ParamName = 'RiskYear' AND ClientName = @clientName)
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'RiskYear' AND ClientName = @clientName
					ELSE
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'RiskYear' AND ClientName IS NULL 
						
					IF @Result IS NULL
						SET @Result = YEAR(GETDATE());
						
                    RETURN @Result
                    END
                        




GO
