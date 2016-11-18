CREATE TABLE [stage].[MemberContact]
(
[CentauriMemberID] [int] NOT NULL,
[Phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
