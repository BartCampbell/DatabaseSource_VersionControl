SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ammar Haider>
-- Create date: <27 Oct, 2015>
-- Description:	<This store procedure will display the data of tblMilestone in divs>
-- [mm_dispData] 
-- =============================================
Create PROCEDURE [dbo].[mm_getMilestoneData] 
	@project int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * from tblMilestone WHERE Project_PK=@project;
END
GO
