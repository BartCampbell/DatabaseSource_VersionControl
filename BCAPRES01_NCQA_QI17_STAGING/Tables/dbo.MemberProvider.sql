CREATE TABLE [dbo].[MemberProvider]
(
[MemberID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateEffective] [smalldatetime] NOT NULL,
[DateTerminated] [smalldatetime] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [actMemberProvider_PK] PRIMARY KEY CLUSTERED  ([MemberID], [ProviderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [actMember_MemberProvider_FK1] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [actProvider_MemberProvider_FK1] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
