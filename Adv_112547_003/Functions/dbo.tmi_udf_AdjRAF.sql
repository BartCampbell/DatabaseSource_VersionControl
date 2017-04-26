SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--PRINT dbo.tmi_udf_AdjRAF(0.292,1.058,0.0341)
CREATE FUNCTION [dbo].[tmi_udf_AdjRAF]
(	
	@RAF Float,
	@FFS Float,
	@CodingIntensity Float
)
RETURNS Float 
AS
BEGIN
	RETURN Round((@RAF/@FFS)*(1-@CodingIntensity),3);
END
GO
