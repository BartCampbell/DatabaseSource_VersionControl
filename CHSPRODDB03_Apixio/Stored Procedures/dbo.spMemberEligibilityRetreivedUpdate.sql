SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Author:			Michael Vlk
Create Date:	2016-07-08
Description:	Update Date_Retreived for a single or all NULL records in MemberEligibility
Usage:		
	EXECUTE dbo.spMemberEligibilityRetreivedUpdate 
		NULL --  @RecID INT -- NULL For all where Date_Retreived IS NULL
		,NULL -- @Date_Retreived DATETIME -- NULL to let proc set to GETDATE() 
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spMemberEligibilityRetreivedUpdate] 
	@RecID INT
	,@Date_Retreived DATETIME
AS
BEGIN

	DECLARE @CurrentDate DATETIME = GETDATE();
	
	SET NOCOUNT ON
	SET XACT_ABORT ON

	UPDATE dbo.MemberEligibility
	SET Date_Retreived = COALESCE(@Date_Retreived,@CurrentDate)
	WHERE 
		Date_Retreived IS NULL
		AND (@RecID IS NULL OR RecID = @RecID)

END
GO
