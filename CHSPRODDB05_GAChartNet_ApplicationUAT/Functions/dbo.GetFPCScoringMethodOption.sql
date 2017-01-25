SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetFPCScoringMethodOption]()
                    RETURNS int
                    AS
                    BEGIN
                    DECLARE @Result int
                    
                    --check for client override value
                    DECLARE @clientName varchar(64)
                    SELECT @clientName = dbo.GetCurrentClient()
                    
                    IF EXISTS (SELECT * FROM dbo.SystemParams WHERE ParamName = 'FPCScoringMethodOption' AND ClientName = @clientName)
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'FPCScoringMethodOption' AND ClientName = @clientName
					ELSE
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'FPCScoringMethodOption' AND ClientName IS NULL 
						
					IF @Result IS NULL
						SET @Result = 2;
						
                    RETURN @Result
                    END
                        




GO
