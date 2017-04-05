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
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[RowFileID] [int] NULL
) ON [PRIMARY]
GO
