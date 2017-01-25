SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetPPCAllowConcurrentScoringRanges]
(
)
RETURNS bit
AS
BEGIN
	
  RETURN (SELECT CONVERT(bit, ISNULL(CASE WHEN (SELECT TOP 1 ParamIntValue FROM dbo.SystemParams WHERE ParamName = 'PPCAllowConcurrentScoringRanges' AND ClientName IS NULL) > 0 THEN 1 END, 0)));

END
GO
