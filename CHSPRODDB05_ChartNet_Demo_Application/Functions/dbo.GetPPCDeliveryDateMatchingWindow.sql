SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[GetPPCDeliveryDateMatchingWindow]()
                    RETURNS INT
                    AS
                    BEGIN
                    DECLARE @Result INT
                    
                    --check for client override value
                    DECLARE @clientName VARCHAR(64)
                    SELECT @clientName = dbo.GetCurrentClient()
                    
                    IF EXISTS (SELECT * FROM dbo.SystemParams WHERE ParamName = 'PPCDeliveryDateMatchingWindow' AND ClientName = @clientName)
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'PPCDeliveryDateMatchingWindow' AND ClientName = @clientName
					ELSE
						SELECT @Result = ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'PPCDeliveryDateMatchingWindow' AND ClientName IS NULL 
						
					IF @Result IS NULL
						SET @Result = 0;
						
                    RETURN @Result
                    END
                        


GO
