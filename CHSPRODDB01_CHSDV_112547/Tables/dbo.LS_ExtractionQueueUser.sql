CREATE TABLE [dbo].[LS_ExtractionQueueUser]
(
[LS_ExtractionQueueUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ExtractionQueueUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ExtractionQueue_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ExtractionQueueUser] ADD CONSTRAINT [PK_LS_ExtractionQueueUser] PRIMARY KEY CLUSTERED  ([LS_ExtractionQueueUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151304] ON [dbo].[LS_ExtractionQueueUser] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ExtractionQueueUser] ADD CONSTRAINT [FK_L_ExtractionQueueUser_RK1] FOREIGN KEY ([L_ExtractionQueueUser_RK]) REFERENCES [dbo].[L_ExtractionQueueUser] ([L_ExtractionQueueUser_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
