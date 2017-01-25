SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ApplyMemberMeasureSampleIDsToPursuitEvent]
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	RV
	SET		MemberMeasureSampleID = MMS.MemberMeasureSampleID
	FROM	dbo.PursuitEvent AS RV
			INNER JOIN dbo.Pursuit AS R
					ON R.PursuitID = RV.PursuitID
			INNER JOIN dbo.Measure AS MM
					ON MM.MeasureID = RV.MeasureID
			INNER JOIN dbo.MemberMeasureSample AS MMS
					ON (MMS.EventDate = RV.EventDate OR MM.HEDISMeasure NOT IN ('MRP','FPC','PPC')) AND
						MMS.MeasureID = RV.MeasureID AND 
						MMS.MemberID = R.MemberID
	WHERE	(RV.MemberMeasureSampleID IS NULL);

END
GO
