CREATE TABLE [dbo].[MemberDuplicates_Cleaned20170210]
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
[CreateDate] [datetime] NULL,
[LastUpdate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Good] [bit] NULL
) ON [PRIMARY]
GO
