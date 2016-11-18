CREATE TABLE [stage].[MemberHICN_MMR]
(
[CentauriMemberID] [int] NOT NULL,
[HICN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
