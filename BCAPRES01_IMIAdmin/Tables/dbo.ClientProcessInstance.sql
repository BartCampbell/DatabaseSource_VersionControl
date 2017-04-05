CREATE TABLE [dbo].[ClientProcessInstance]
(
[InstanceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ClientProcessInstance_InstanceID] DEFAULT (newid()),
[ClientProcessID] [uniqueidentifier] NOT NULL,
[DateBeginLoadDataStore] [datetime] NULL,
[DateEndLoadDataStore] [datetime] NULL,
[DateBeginLoadRDSM] [datetime] NULL,
[DateEndLoadRDSM] [datetime] NULL,
[DateBeginLoadWarehouse] [datetime] NULL,
[DateEndLoadWarehouse] [datetime] NULL,
[DateBeginProcessDataStore] [datetime] NULL,
[DateEndProcessDataStore] [datetime] NULL,
[InstanceBegin] [datetime] NOT NULL,
[InstanceEnd] [datetime] NULL,
[JobID] [uniqueidentifier] NULL,
[LastStatus] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcessInstance] ADD CONSTRAINT [PK_ClientProcessInstance] PRIMARY KEY CLUSTERED  ([InstanceID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClientProcessInstance] ON [dbo].[ClientProcessInstance] ([LoadInstanceID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcessInstance] ADD CONSTRAINT [FK_ClientProcessInstance_ClientProcess] FOREIGN KEY ([ClientProcessID]) REFERENCES [dbo].[ClientProcess] ([ClientProcessID])
GO
