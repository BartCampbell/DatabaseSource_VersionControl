CREATE TABLE [Result].[MemberMonthDetail]
(
[Age] [tinyint] NOT NULL,
[AgeMonths] [smallint] NOT NULL,
[BatchID] [int] NOT NULL,
[BenefitID] [int] NOT NULL CONSTRAINT [DF_MemberMonthDetail_BenefitID] DEFAULT ((0)),
[BitBenefits] [bigint] NOT NULL CONSTRAINT [DF_MemberMonthDetail_BitBenefits] DEFAULT ((0)),
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_MemberMonthDetail_BitProductLines] DEFAULT ((0)),
[CountMonths] [int] NOT NULL CONSTRAINT [DF_MemberMonthDetail_CountMonths] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EnrollGroupID] [int] NOT NULL,
[Gender] [tinyint] NOT NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[ProductLineID] [smallint] NOT NULL CONSTRAINT [DF_MemberMonthDetail_ProductLineID] DEFAULT ((0)),
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MemberMonthDetail_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MemberMonthDetail] ADD CONSTRAINT [PK_MemberMonthDetail] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMonthDetail_Benefits] ON [Result].[MemberMonthDetail] ([BitBenefits], [BitProductLines], [DataRunID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberMonthDetail] ON [Result].[MemberMonthDetail] ([DataRunID], [DSMemberID], [PopulationID], [BitProductLines], [Age], [BitBenefits], [EnrollGroupID]) INCLUDE ([CountMonths], [DataSetID]) ON [PRIMARY]
GO
