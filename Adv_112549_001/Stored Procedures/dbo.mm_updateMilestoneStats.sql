SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Syed Ammar Haider>
-- Create date: <10 Nov, 2015>
-- Description:	<this SP will update the the goals in tblMilestone>
-- =============================================
--mm_updateMilestoneStats 1
CREATE PROCEDURE [dbo].[mm_updateMilestoneStats] 
	-- Add the parameters for the stored procedure here
	@Milestone_PK int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update tblMilestone SET [Milestone_Goal] = (SELECT SUM(Goal) FROM tblMilestoneDetail WHERE [Milestone_PK]=@Milestone_PK)
		WHERE Milestone_PK=@Milestone_PK
END
GO
