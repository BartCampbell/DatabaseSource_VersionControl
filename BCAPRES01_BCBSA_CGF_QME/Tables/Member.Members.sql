CREATE TABLE [Member].[Members]
(
[CustomerMemberID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL CONSTRAINT [DF__Members__DataSou__14259B31] DEFAULT ((-1)),
[DOB] [datetime] NULL,
[DSMemberID] [bigint] NOT NULL IDENTITY(1, 1),
[Gender] [tinyint] NULL,
[IhdsMemberID] [int] NOT NULL,
[MemberID] [int] NOT NULL,
[NameFirst] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[Members] ADD CONSTRAINT [PK_Members] PRIMARY KEY CLUSTERED  ([DSMemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Members_CustomerMemberID] ON [Member].[Members] ([CustomerMemberID], [DataSetID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Members_DataSetID] ON [Member].[Members] ([DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Members_IhdsMemberID] ON [Member].[Members] ([IhdsMemberID], [DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Members_MemberID] ON [Member].[Members] ([MemberID], [DataSetID]) ON [PRIMARY]
GO
