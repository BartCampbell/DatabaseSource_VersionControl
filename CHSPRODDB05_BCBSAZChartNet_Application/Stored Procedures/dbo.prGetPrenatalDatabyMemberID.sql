SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks - jbfranks@gmail.com
-- Create date: 1/25/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prGetPrenatalDatabyMemberID] 
	-- Add the parameters for the stored procedure here
    @MemberID INT
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

        SELECT  PAMeasureIntakeID ,
                MemberID ,
                QuestionA ,
                QuestionB ,
                SmokingQuestion1 ,
                SmokingQuestion2 ,
                SmokingQuestion3 ,
                SmokingQuestion4 ,
                SmokingQuestion5 ,
                SmokingQuestion6 ,
                SmokingQuestion7 ,
                SmokingQuestion8 ,
                DepressionQuestion1 ,
                DepressionQuestion1a ,
                DepressionQuestion2 ,
                DepressionQuestion3 ,
                SmokingQuestion1_Date ,
                SmokingQuestion4_Date ,
                SmokingQuestion5_Date ,
                SmokingQuestion6_Date ,
                SmokingQuestion8_Date ,
                DepressionQuestion1_Date ,
                DepressionQuestion1a_Date ,
                DepressionQuestion2_Date ,
                DepressionQuestion3_Date ,
                QuestionA_Date ,
                QuestionB1_Date ,
                QuestionB2_Date ,
                DepressionScreeningTool ,
                PostpartumQuestionA ,
                PostpartumQuestionA_Date ,
                PostpartumQuestion4 ,
                PostpartumQuestion4_Date ,
                PostpartumQuestion4a ,
                PostpartumQuestion4a_Date ,
                PostpartumQuestion5 ,
                PostpartumQuestion5_Date ,
                PostpartumQuestion6 ,
                PostpartumQuestion6_Date ,
                PostpartumScreeningTool
        FROM    PAMeasureIntake
        WHERE   MemberID = @MemberID
           
    END
GO
GRANT EXECUTE ON  [dbo].[prGetPrenatalDatabyMemberID] TO [ChartNet_AppUser_Custom]
GO
