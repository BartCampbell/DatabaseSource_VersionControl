CREATE TABLE [stage].[SuspectDOS_ADV]
(
[CentauriSuspectID] [int] NOT NULL,
[SuspectDOS_PK] [bigint] NOT NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_To] [smalldatetime] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
