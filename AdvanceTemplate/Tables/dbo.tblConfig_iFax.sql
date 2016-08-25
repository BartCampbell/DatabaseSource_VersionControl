CREATE TABLE [dbo].[tblConfig_iFax]
(
[location_charts] [smallint] NULL,
[isFaxIn] [tinyint] NULL,
[isMailIn] [tinyint] NULL,
[isEmail] [tinyint] NULL,
[DaysSinceLastContact] [smallint] NULL,
[DaysBeforeSchReturn] [smallint] NULL,
[DaysPastSchReturn] [smallint] NULL,
[DaysSinceLastFax] [smallint] NULL,
[IssueLocations] [tinyint] NULL,
[StopEngine] [tinyint] NULL
) ON [PRIMARY]
GO
