CREATE TABLE [dbo].[S_RAPS_Response_AAA]
(
[S_RAPS_Response_AAAID] [bigint] NOT NULL IDENTITY(1, 1),
[S_RAPS_Response_AAA_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubmitterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdTestIND] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileDiagType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_S_RAPS_Response_AAA_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_AAA] ADD CONSTRAINT [PK_S_RAPS_Response_AAA] PRIMARY KEY CLUSTERED  ([S_RAPS_Response_AAAID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_EndDate] ON [dbo].[S_RAPS_Response_AAA] ([RecordEndDate]) INCLUDE ([H_RAPS_Response_RK], [HashDiff], [S_RAPS_Response_AAA_RK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_S_RAPS_Response_AAA] ON [dbo].[S_RAPS_Response_AAA] ([S_RAPS_Response_AAA_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_AAA] ADD CONSTRAINT [FK_S_RAPS_Response_AAA_H_RAPS_Response] FOREIGN KEY ([H_RAPS_Response_RK]) REFERENCES [dbo].[H_RAPS_Response] ([H_RAPS_Response_RK])
GO
