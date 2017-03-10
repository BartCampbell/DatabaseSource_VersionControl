SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/3/2012
-- Description:	Retrieve the description for the specified measure component evidence.
-- =============================================
CREATE FUNCTION [dbo].[GetMeasureComponentEvidence]
(
	@HEDISMeasure varchar(50),
	@ListKey varchar(50),
	@MeasureEvidenceID int
)
RETURNS varchar(255)
AS
BEGIN
	
	DECLARE @Result varchar(255);

	SELECT	@Result = DisplayText 
	FROM	dbo.MeasureComponentEvidence AS MCE WITH(NOLOCK)
			INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK)
					ON MCE.MeasureComponentID = MC.MeasureComponentID
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON MC.MeasureID = M.MeasureID
					
	WHERE	MCE.MeasureEvidenceID = @MeasureEvidenceID AND 
			MCE.ListKey = @ListKey AND
			M.HEDISMeasure = @HEDISMeasure;

	RETURN @Result;

END
GO
