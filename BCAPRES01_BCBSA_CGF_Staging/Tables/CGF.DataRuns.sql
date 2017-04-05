CREATE TABLE [CGF].[DataRuns]
(
[BeginSeedDate] [datetime] NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[DataRunGuid] [uniqueidentifier] NOT NULL,
[DataSetGuid] [uniqueidentifier] NOT NULL,
[EndSeedDate] [datetime] NOT NULL,
[MeasureSet] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberMonths] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
