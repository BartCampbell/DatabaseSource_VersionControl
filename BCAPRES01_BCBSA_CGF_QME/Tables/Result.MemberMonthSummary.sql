CREATE TABLE [Result].[MemberMonthSummary]
(
[Age] [tinyint] NOT NULL,
[BatchID] [int] NULL,
[BenefitID] [smallint] NOT NULL,
[CountMembers] [bigint] NOT NULL,
[CountMonths] [bigint] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollGroupID] [int] NOT NULL,
[Gender] [tinyint] NOT NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MemberMonthSummary_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MemberMonthSummary] ADD CONSTRAINT [PK_MemberMonthSummary] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMonthSummary_AgeBands] ON [Result].[MemberMonthSummary] ([Age], [Gender], [ProductLineID], [DataRunID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMonthSummary_Benefits] ON [Result].[MemberMonthSummary] ([BenefitID], [ProductLineID], [DataRunID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberMonthSummary] ON [Result].[MemberMonthSummary] ([DataRunID], [BenefitID], [PopulationID], [PayerID], [ProductLineID], [EnrollGroupID], [Age], [Gender], [BatchID]) ON [PRIMARY]
GO
