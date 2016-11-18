CREATE TABLE [stage].[MemberClient_RAPS]
(
[CentauriMemberID] [int] NOT NULL,
[CentauriClientID] [int] NOT NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
