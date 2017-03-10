CREATE TABLE [Log].[ProcessErrors]
(
[Application] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchID] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[EngineGuid] [uniqueidentifier] NULL,
[ErrorNumber] [int] NULL,
[ErrorType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogError_ErrorType] DEFAULT (N'X'),
[Host] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Info] [xml] NULL,
[IPAddress] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSynced] [bit] NOT NULL CONSTRAINT [DF_ProcessErrors_IsSynced] DEFAULT ((0)),
[LineNumber] [int] NULL,
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_LogError_ErrorDate] DEFAULT (getdate()),
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogUser] [nvarchar] (384) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LogError_ErrorUser] DEFAULT (suser_sname()),
[MeasureSetID] [int] NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OwnerID] [int] NULL,
[Severity] [int] NULL,
[Source] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpId] [int] NULL,
[State] [int] NULL,
[Stack] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Target] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Log].[ProcessErrors] ADD CONSTRAINT [PK_Log_ProcessErrors] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
