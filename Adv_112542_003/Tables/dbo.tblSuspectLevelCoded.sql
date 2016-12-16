CREATE TABLE [dbo].[tblSuspectLevelCoded]
(
[CoderLevel] [tinyint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[dtInserted] [smalldatetime] NULL,
[IsCompleted] [bit] NULL,
[ReceivedAdditionalPages] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectLevelCoded] ADD CONSTRAINT [PK_tblSuspectLevelCoded] PRIMARY KEY CLUSTERED  ([CoderLevel], [Suspect_PK], [User_PK]) ON [PRIMARY]
GO
