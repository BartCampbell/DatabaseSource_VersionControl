CREATE TABLE [dbo].[CodingTrend]
(
[ChartsLeft] [int] NULL,
[TimeStamp] [datetime] NULL CONSTRAINT [DF_CodingTrend_TimeStamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
