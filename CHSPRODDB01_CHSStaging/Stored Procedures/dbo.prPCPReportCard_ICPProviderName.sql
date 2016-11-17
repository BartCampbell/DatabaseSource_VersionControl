SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prPCPReportCard_ICPProviderName]
	-- Add the parameters for the stored procedure here
	@GroupID varchar(15),
	@ProviderID varchar(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	Providername
	from CHSLib.dbo.DB_CCAI_ICPTopBottomMeasures with(nolock)
	where len(providerID) <> 0
	and GroupID not in ('50th Percentile','75th Percentile')
	and ReportLevel='P'
	and providerid<>'99999'
	and GroupID = @GroupID
	and ProviderID = @ProviderID
	group by Providername

END
GO
