SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RunPostScoringSteps]
(
 @HedisMeasure varchar(16) = NULL,
 @MemberID int
)
AS 
BEGIN
    SET NOCOUNT ON;

	DECLARE @TableName nvarchar(128);
	SET @TableName = '##RescoringMeasure_' + CONVERT(nvarchar(128), @@SPID);

	PRINT 'Running Post Scoring Steps...';
    EXEC dbo.ApplySampleVoid @HedisMeasure = @HedisMeasure, @MemberID = @MemberID;
	EXEC dbo.ValidateExclusions @HedisMeasure = @HedisMeasure, @MemberID = @MemberID;
    
	IF OBJECT_ID('tempdb..' + @TableName) IS NULL
		EXEC dbo.CalculateReportedScoring @HedisMeasure = @HedisMeasure, @MemberID = @MemberID;
    
END
GO
