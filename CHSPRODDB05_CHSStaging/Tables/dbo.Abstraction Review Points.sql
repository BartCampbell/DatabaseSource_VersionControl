CREATE TABLE [dbo].[Abstraction Review Points]
(
[MeasureID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISMeasure] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureComponentID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TabDisplayTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ Default ReviewPointsAvailable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Default EnabledOnReviews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ Custom ReviewPointsAvailable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Custom EnabledOnReviews] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
