CREATE TABLE [dim].[Member]
(
[MemberID] [int] NOT NULL IDENTITY(1, 1),
[CentauriMemberID] [int] NOT NULL,
[SSN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [int] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_Member_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_Member_LastUpdate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Member] ADD CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Member_17_1067150847__K2] ON [dim].[Member] ([CentauriMemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Member_10_1406628054__K1] ON [dim].[Member] ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberID] ON [dim].[Member] ([MemberID]) INCLUDE ([CentauriMemberID]) ON [PRIMARY]
GO
