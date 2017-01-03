CREATE TABLE [dbo].[tblChannelLog]
(
[ChannelLog_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NULL,
[From_Channel_PK] [int] NULL,
[To_Channel_PK] [int] NULL,
[User_PK] [int] NULL,
[dtUpdate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblChannelLog] ADD CONSTRAINT [PK_tblChannelLog] PRIMARY KEY CLUSTERED  ([ChannelLog_PK]) ON [PRIMARY]
GO
