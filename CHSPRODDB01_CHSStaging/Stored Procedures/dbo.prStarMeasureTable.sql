SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








-- =============================================
-- Author:		Brandon Rodman	
-- Create date: 09/21/2016
-- Description:	Pulls data for the Stars reports/graphs
-- =============================================
CREATE PROCEDURE [dbo].[prStarMeasureTable] 
	@StarMeasureCategory varchar(25)


	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--declare @ClientName varchar(25);
--declare @Location varchar(25);
--declare @ReportDate date;

--set @ClientName = 'WellCare';
--set @Location = 'Scottsdale';
--set @ReportDate = '07/22/2016';

set ANSI_Warnings OFF;


    select [Star Rating Year],
         [MeasurementMonth],
		 [StarMeasureCategory],
		 [StarMeasureSubCategory],
		 AVG([Estimated Star]) as AVERawStar,
		 AVG([Weighted Star]) as AVEWeightedStar,
		 AVG([Target Star]) as AVETargetStar,
		 AVG([Estimated Metric]) as AVEMetric,
		 AVG ([Target Metric]) as AVETargetCutPercentage,
		 SUM([Weighted Star]) as SUMWeightedStar
		 From [CHSStaging].[dbo].[StarsSummaryPresentationData]
		 where StarMeasureCategory = @StarMeasureCategory
		 group by [Star Rating Year], [MeasurementMonth], [StarMeasureCategory], [StarMeasureSubCategory]

End



GO
