SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Syed Ammar Haider>
-- Create date: <10 Nov, 2015>
-- Description:	<This store procedure will update the goals as perday and also the milestone goals>
-- =============================================
CREATE PROCEDURE [dbo].[mm_updateMilestone] 
	@mspk int,
	@dates date,
	@goals int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [dbo].[tblMilestoneDetail]
	SET Goal=@goals 
	WHERE [Milestone_PK]=@mspk and [dtGoal]=@dates
	
END
GO
