SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prChannelChaseCounts]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


select t1.PROJECT as Channel,
              case
                     when t2.Project_PK = 2
                           then 'FL'
                     when t2.Project_PK = 1
                           then 'NY'
              end as ProjectName,
              sum(case
                     when t2.IsScanned = 1
                           then 1
                     else 0
              end) as ChartsScanned,
              count(distinct t1.[Chart ID]) as TotalCharts
from CHSStaging.dbo.WellCareMasterChaseList_20160929 t1
join Adv_112547_001.dbo.tblSuspect t2
on t1.[Chart ID] = t2.ChaseID
where IsCentauri = 1
group by t1.PROJECT,
              case
                     when t2.Project_PK = 2
                           then 'FL'
                     when t2.Project_PK = 1
                           then 'NY'
              end
order by t1.PROJECT



END

GO
