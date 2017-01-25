CREATE TABLE [dbo].[TestDeckResultsSubMetric]
(
[TestDeckResultsSubMetricID] [int] NOT NULL IDENTITY(1, 1),
[TestDeckResultsID] [int] NOT NULL,
[HEDISSubMetricID] [int] NOT NULL,
[SavedResult] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TestDeckResultsSubMetric] ADD CONSTRAINT [PK__TestDeckResultsS__6F357288] PRIMARY KEY CLUSTERED  ([TestDeckResultsSubMetricID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TestDeckResultsSubMetric] WITH NOCHECK ADD CONSTRAINT [TestDeckResultsSubMetric_HEDISSubMetric] FOREIGN KEY ([HEDISSubMetricID]) REFERENCES [dbo].[HEDISSubMetric] ([HEDISSubMetricID])
GO
ALTER TABLE [dbo].[TestDeckResultsSubMetric] ADD CONSTRAINT [TestDeckResultsSubMetric_TestDeckResults] FOREIGN KEY ([TestDeckResultsID]) REFERENCES [dbo].[TestDeckResults] ([TestDeckResultsID])
GO
