SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ScorePA]
(
	@MemberID int
)
AS
BEGIN
	---------------------------------------------------------------------------------------------------------------------------------------
	--IMPORTANT:	Because the ChartNet PA Measures were built to share some functionality (in regard to the DOD and first-two-visits),
	--				rescoring a single measure, needs to rescore all measures to ensure the impact of recent changes are correctly
	--				represented in measure-level reports.
	---------------------------------------------------------------------------------------------------------------------------------------

	EXEC dbo.ScorePPC @MemberID = @MemberID; --Prerequisite for identifying the denominators of the PA PM measures.	

	EXEC dbo.ScorePDS @MemberID = @MemberID;
	EXEC dbo.ScorePSS @MemberID = @MemberID;
	EXEC dbo.ScoreMRFA @MemberID = @MemberID;

END
GO
