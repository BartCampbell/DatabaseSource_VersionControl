CREATE TABLE [raps].[RAPS_RESPONSE_AAA]
(
[RecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmitterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdTestIND] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDiagType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseFileID] [int] NOT NULL IDENTITY(1, 1),
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_RAPS_Response_AAA_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [raps].[RAPS_RESPONSE_AAA] ADD CONSTRAINT [PK_RAPS_RESPONSE_AAA] PRIMARY KEY CLUSTERED  ([ResponseFileID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
