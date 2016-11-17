CREATE TABLE [adv].[tmpmemberfix]
(
[CentauriMemberID] [int] NOT NULL,
[SSN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAXH] [bit] NULL
) ON [PRIMARY]
GO
