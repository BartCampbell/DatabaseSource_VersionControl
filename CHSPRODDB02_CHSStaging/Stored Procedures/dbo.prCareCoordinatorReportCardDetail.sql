SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prCareCoordinatorReportCardDetail] 
	@CareCoordinator varchar(100),
	@ReportYear int,
	@ReportMonth int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--    -- Insert statements for procedure here
	


---- ****** THE CCAI Care Coordinator Reports
select *
from(
select	ReportYear,
		ReportMonth,
		GroupID,
		GroupName,
		ProviderID,
		ProviderName,
		Mem_nbr as MemberID,
		FirstName+' '+LastName as MemberName,
		MeasureCode,
		MeasureDescription,
		SubrateDescription,
		Numerator,
		Denominator,
		DOB as MemberDOB,
		AgeAtEndofRptYear as MemberAGe,
		Gender as MemberGender,
		CareCoordinator,
		Row_Number() over(partition by Mem_nbr, MeasureCode, MeasureDescription, SubrateDescription order by isnull(Gender,'') desc) as RowNum
	 from CHSLib.dbo.DB_CCAITopBottomMeasures_Detail 
	 where Numerator=1
	and Denominator>0
	and ReportYear = @ReportYear
	and CareCoordinator = @CareCoordinator
	and ReportMonth = @ReportMonth

	)t1
where t1.RowNum = 1






END

GO
