CREATE TABLE [Measure].[Enrollment]
(
[AdminGapDays] [smallint] NOT NULL CONSTRAINT [DF_MeasureEnrollment_AdminGapDays] DEFAULT ((0)),
[AdminGaps] [smallint] NOT NULL CONSTRAINT [DF_MeasureEnrollment_AdminGaps] DEFAULT ((0)),
[AnchorDays] [smallint] NULL,
[AnchorMonths] [smallint] NULL,
[BeginDays] [smallint] NOT NULL,
[BeginDOBDays] [smallint] NOT NULL,
[BeginDOBMonths] [smallint] NOT NULL,
[BeginMonths] [smallint] NOT NULL,
[DateComparerID] [smallint] NOT NULL,
[EndDays] [smallint] NOT NULL,
[EndDOBDays] [smallint] NOT NULL,
[EndDOBMonths] [smallint] NOT NULL,
[EndMonths] [smallint] NOT NULL,
[GapDays] [smallint] NOT NULL CONSTRAINT [DF_MeasureEnrollment_GapDays] DEFAULT ((0)),
[Gaps] [smallint] NOT NULL CONSTRAINT [DF_MeasureEnrollment_Gaps] DEFAULT ((0)),
[Gender] [tinyint] NULL,
[PayerDays] [smallint] NULL,
[PayerMonths] [smallint] NULL,
[MeasEnrollGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureEnrollment_MeasEnrollGuid] DEFAULT (newid()),
[MeasEnrollID] [int] NOT NULL IDENTITY(1, 1),
[MeasureSetID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[Enrollment] ADD CONSTRAINT [PK_MeasureEnrollment] PRIMARY KEY CLUSTERED  ([MeasEnrollID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureEnrollment_MeasEnrollGuid] ON [Measure].[Enrollment] ([MeasEnrollGuid]) ON [PRIMARY]
GO
