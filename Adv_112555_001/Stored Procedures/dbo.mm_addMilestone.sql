SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ammar Haider
-- Create date: 20 October, 2015
-- Description:	This store procedure will be used to manage the data of milestone manager
--[mm_insertData] 1,'10/01/2015',0
-- =============================================
CREATE PROCEDURE [dbo].[mm_addMilestone]
	@project int,
	@goal int,
	@milestone_type int,
	@dt_from smalldatetime, 
	@dt_to smalldatetime, 
	@perday int,
	@isActive binary 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MilestonePK AS INT
	DECLARE @STDATE AS DATETIME
	DECLARE @ENDDATE AS DATETIME
	DECLARE @DAYS AS INT
	SET @STDATE= @dt_from
	SET @ENDDATE=@dt_to

    -- Insert statements for procedure here
	INSERT INTO [dbo].[tblMilestone] 
		(Project_PK,[Milestone_Goal],[MilestoneType_PK],[dt_from],[dt_to],[isActive])
	VALUES 
		(@project,@goal,@milestone_type,@dt_from,@dt_to,@isActive)

	SELECT @MilestonePK=@@IDENTITY;

	WHILE (@STDATE<=@ENDDATE)
	BEGIN
		IF DATEPART(dw, @STDATE) NOT IN (1,7)
			INSERT INTO [dbo].[tblMilestoneDetail] ([Milestone_PK], [dtGoal],[Goal]) VALUES (@MilestonePK,@STDATE,@perday)

		SET @STDATE = dateadd(day,1,@STDATE)
	END
END
GO
