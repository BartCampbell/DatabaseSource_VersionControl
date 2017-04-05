CREATE TABLE [Log].[ProcessEntries]
(
[BatchID] [int] NULL,
[BeginTime] [datetime] NULL,
[CountRecords] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NOT NULL,
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndTime] [datetime] NULL,
[EngineGuid] [uniqueidentifier] NULL,
[EntryXrefGuid] [uniqueidentifier] NULL,
[EntryXrefID] [int] NULL,
[ErrLogID] [int] NULL,
[ExecObjectGuid] [uniqueidentifier] NULL,
[ExecObjectID] [smallint] NULL,
[IsSuccess] [bit] NOT NULL CONSTRAINT [DF_Progress_IsSuccess] DEFAULT ((0)),
[IsSynced] [bit] NOT NULL CONSTRAINT [DF_ProcessEntries_IsSubmitted] DEFAULT ((0)),
[Iteration] [tinyint] NULL,
[LogDate] [datetime] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetID] [int] NULL,
[OwnerID] [int] NOT NULL,
[SrcObjectGuid] [uniqueidentifier] NOT NULL,
[SrcObjectID] [smallint] NULL,
[StepNbr] [smallint] NULL,
[StepTot] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[ProcessEntries] ADD CONSTRAINT [PK_Log_ProcessEntries] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
