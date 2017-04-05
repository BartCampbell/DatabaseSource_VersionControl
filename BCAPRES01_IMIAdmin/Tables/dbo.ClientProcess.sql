CREATE TABLE [dbo].[ClientProcess]
(
[ClientProcessID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ClientProcess_ClientProcessID] DEFAULT (newid()),
[ClientID] [uniqueidentifier] NOT NULL,
[HoursBetweenRuns] [smallint] NOT NULL,
[IsStatusingAtRuleStepLevel] [bit] NULL,
[ProcessID] [uniqueidentifier] NULL,
[SuspectThreshold] [decimal] (4, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcess] ADD CONSTRAINT [PK_ClientProcess] PRIMARY KEY CLUSTERED  ([ClientProcessID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcess] ADD CONSTRAINT [FK_ClientProcess_Client] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Client] ([ClientID])
GO
ALTER TABLE [dbo].[ClientProcess] ADD CONSTRAINT [FK_ClientProcess_Process] FOREIGN KEY ([ProcessID]) REFERENCES [dbo].[Process] ([ProcessID])
GO
