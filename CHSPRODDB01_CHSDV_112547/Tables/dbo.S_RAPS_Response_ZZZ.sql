CREATE TABLE [dbo].[S_RAPS_Response_ZZZ]
(
[S_RAPS_Response_ZZZID] [bigint] NOT NULL IDENTITY(1, 1),
[S_RAPS_Response_ZZZ_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubmitterID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BBBRecordTotal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_S_RAPS_Response_ZZZ_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_ZZZ] ADD CONSTRAINT [PK_S_RAPS_Response_ZZZ] PRIMARY KEY CLUSTERED  ([S_RAPS_Response_ZZZID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_EndDate] ON [dbo].[S_RAPS_Response_ZZZ] ([RecordEndDate]) INCLUDE ([H_RAPS_Response_RK], [HashDiff], [S_RAPS_Response_ZZZ_RK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_S_RAPS_Response_ZZZ] ON [dbo].[S_RAPS_Response_ZZZ] ([S_RAPS_Response_ZZZ_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_RAPS_Response_ZZZ] ADD CONSTRAINT [FK_S_RAPS_Response_ZZZ_H_RAPS_Response] FOREIGN KEY ([H_RAPS_Response_RK]) REFERENCES [dbo].[H_RAPS_Response] ([H_RAPS_Response_RK])
GO
