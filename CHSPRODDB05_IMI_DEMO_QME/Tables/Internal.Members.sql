CREATE TABLE [Internal].[Members]
(
[BatchID] [int] NOT NULL,
[CustomerMemberID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[DOB] [datetime] NULL,
[DSMemberID] [bigint] NOT NULL,
[Gender] [tinyint] NULL,
[IhdsMemberID] [int] NULL,
[MemberID] [int] NULL,
[NameFirst] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameLast] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_Members_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[Members] ADD CONSTRAINT [PK_Internal_Members] PRIMARY KEY CLUSTERED  ([SpId], [DSMemberID]) ON [PRIMARY]
GO
