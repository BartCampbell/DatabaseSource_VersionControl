CREATE TABLE [dbo].[FileProcessStepLog]
(
[FileProcessStepLogID] [int] NOT NULL IDENTITY(1000000, 1),
[FileLogID] [int] NOT NULL,
[FileProcessID] [int] NOT NULL,
[FileProcessStepID] [int] NOT NULL,
[FileProcessStepDate] [datetime] NOT NULL CONSTRAINT [DF__FileProce__FileP__7ABC33CD] DEFAULT (getdate()),
[StatusID] [int] NOT NULL,
[RecordCount] [int] NULL,
[ErrorDesc] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStepLog] ADD CONSTRAINT [PK_FileProcessStepLog] PRIMARY KEY CLUSTERED  ([FileProcessStepLogID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FileProcessStepLog] ADD CONSTRAINT [FK_FileProcessStepLog_FileLog] FOREIGN KEY ([FileLogID]) REFERENCES [dbo].[FileLog] ([FileLogID])
GO
ALTER TABLE [dbo].[FileProcessStepLog] ADD CONSTRAINT [FK_FileProcessStepLog_FileProcess] FOREIGN KEY ([FileProcessID]) REFERENCES [dbo].[FileProcess] ([FileProcessID])
GO
ALTER TABLE [dbo].[FileProcessStepLog] ADD CONSTRAINT [FK_FileProcessStepLog_FileProcessStep] FOREIGN KEY ([FileProcessStepID]) REFERENCES [dbo].[FileProcessStep] ([FileProcessStepID])
GO
