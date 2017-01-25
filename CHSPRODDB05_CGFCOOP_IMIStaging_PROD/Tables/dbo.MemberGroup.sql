CREATE TABLE [dbo].[MemberGroup]
(
[MemberGroupID] [int] NOT NULL IDENTITY(1, 1),
[MemberGroupName1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGroupName2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerGroupID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberGroupID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressLine2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SICCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[RowFileID] [int] NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberGroup] ADD CONSTRAINT [pk_membergroup] PRIMARY KEY CLUSTERED  ([MemberGroupID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_pk_membergroup] ON [dbo].[MemberGroup] ([MemberGroupID])
GO
