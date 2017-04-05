CREATE TABLE [dbo].[ClientProcessInstanceFile]
(
[LoadInstanceFileID] [int] NOT NULL IDENTITY(1, 1),
[LoadInstanceID] [int] NOT NULL,
[InboundFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InboundFilePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InboundMachine] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateReceived] [datetime] NULL,
[DateFile] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcessInstanceFile] ADD CONSTRAINT [PK_ClientProcessInstanceFile] PRIMARY KEY CLUSTERED  ([LoadInstanceFileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcessInstanceFile] ADD CONSTRAINT [FK_ClientProcessInstanceFile_ClientProcessInstance] FOREIGN KEY ([LoadInstanceID]) REFERENCES [dbo].[ClientProcessInstance] ([LoadInstanceID])
GO
