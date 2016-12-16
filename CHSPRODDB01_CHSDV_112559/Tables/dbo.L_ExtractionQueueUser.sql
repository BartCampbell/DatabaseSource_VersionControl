CREATE TABLE [dbo].[L_ExtractionQueueUser]
(
[L_ExtractionQueueUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ExtractionQueue_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ExtractionQueueUser] ADD CONSTRAINT [PK_L_ExtractionQueueUser] PRIMARY KEY CLUSTERED  ([L_ExtractionQueueUser_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ExtractionQueueUser] ADD CONSTRAINT [FK_H_ExtractionQueue_RK] FOREIGN KEY ([H_ExtractionQueue_RK]) REFERENCES [dbo].[H_ExtractionQueue] ([H_ExtractionQueue_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ExtractionQueueUser] ADD CONSTRAINT [FK_H_User_RK30] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
