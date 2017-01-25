SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Export].[PAPregnancy] AS 
SELECT	MBR.CustomerMemberID,
		MBR.ProductLine,
		MBR.Product,
		R.PursuitNumber,
		PA.PAMeasureIntakeID AS IMIReferenceNumber,
		RV.EventDate,
        PA.QuestionA,
		PA.QuestionA_Date,
        PA.QuestionB,
		PA.QuestionB1_Date,
        PA.QuestionB2_Date,
        PA.SmokingQuestion1,
		PA.SmokingQuestion1_Date,
        PA.SmokingQuestion2,
        --PA.SmokingQuestion3,  --Removed 2015, Questions Pseudo-renumbered...
        PA.SmokingQuestion4 AS SmokingQuestion3,
		PA.SmokingQuestion4_Date AS SmokingQuestion3_Date,
        PA.SmokingQuestion5 AS SmokingQuestion4,
		PA.SmokingQuestion5_Date AS SmokingQuestion4_Date,
        PA.SmokingQuestion6 AS SmokingQuestion5,
		PA.SmokingQuestion6_Date AS SmokingQuestion5_Date,
        PA.SmokingQuestion7 AS SmokingQuestion6,
        PA.SmokingQuestion8 AS SmokingQuestion7,
		PA.SmokingQuestion8_Date AS SmokingQuestion7_Date,
        PA.DepressionQuestion1,
        PA.DepressionQuestion1_Date,
		PA.DepressionQuestion1a,
        PA.DepressionQuestion1a_Date,
		PA.DepressionQuestion2,
        PA.DepressionQuestion2_Date,
		PA.DepressionQuestion3,
        PA.DepressionQuestion3_Date,
        CASE WHEN PA.DepressionQuestion1a = 1 THEN PDST2.ToolDesc ELSE NULL END AS DepressionScreeningTool,
		CASE WHEN PA.DepressionQuestion1a = 1 THEN PDST2.ToolDBID ELSE NULL END AS DepressionScreeningToolDBID,
        PA.PostpartumQuestionA,
        PA.PostpartumQuestionA_Date,
        PA.PostpartumQuestion4,
        PA.PostpartumQuestion4_Date,
        PA.PostpartumQuestion4a,
        PA.PostpartumQuestion4a_Date,
        PA.PostpartumQuestion5,
        PA.PostpartumQuestion5_Date,
        PA.PostpartumQuestion6,
        PA.PostpartumQuestion6_Date,
        CASE WHEN PA.PostpartumQuestion4a = 1 THEN PDST1.ToolDesc ELSE NULL END AS PostpartumScreeningTool,
		CASE WHEN PA.PostpartumQuestion4a = 1 THEN PDST1.ToolDBID ELSE NULL END AS PostpartumScreeningToolDBID,
		PA.RiskFactorQuestion1,
		PA.RiskFactorQuestion1_Date,
		PA.RiskFactorQuestion2,
		PA.RiskFactorQuestion2_Date,
		PA.RiskFactorQuestion3,
		PA.RiskFactorQuestion3_Date,
		PA.RiskFactorQuestion4,
		PA.RiskFactorQuestion4_Date,
        PA.CreatedDate,
        PA.LastUpdatedDate
FROM	dbo.PAMeasureIntake AS PA				
		INNER JOIN dbo.PursuitEvent AS RV
				ON RV.PursuitEventID = PA.PursuitEventID
		INNER JOIN dbo.Pursuit AS R
				ON RV.PursuitID = R.PursuitID		
		INNER JOIN dbo.Member AS MBR
				ON MBR.MemberID = R.MemberID
		INNER JOIN dbo.Measure AS M
				ON RV.MeasureID = M.MeasureID AND
					M.HEDISMeasure = 'PPC'              
		LEFT OUTER JOIN dbo.PrenatalDepressionScreeningTools AS PDST1
				ON PA.PostpartumScreeningTool = PDST1.ToolDBID
		LEFT OUTER JOIN dbo.PrenatalDepressionScreeningTools AS PDST2
				ON PA.DepressionScreeningTool = PDST2.ToolDBID

GO
