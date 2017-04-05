CREATE TABLE [Result].[DataSetMemberKey]
(
[CustomerMemberID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DisplayID] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DOB] [datetime] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[Gender] [tinyint] NOT NULL,
[HicNumber] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IhdsMemberID] [int] NOT NULL,
[NameDisplay] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameFirst] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameObscure] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanId] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SnpType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SsnDisplay] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SsnObscure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMemberKey] ADD CONSTRAINT [PK_DataSetMemberKey] PRIMARY KEY CLUSTERED  ([DataRunID], [DSMemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_DataSetMemberKey] ON [Result].[DataSetMemberKey] ([CustomerMemberID], [DataRunID]) ON [PRIMARY]
GO
