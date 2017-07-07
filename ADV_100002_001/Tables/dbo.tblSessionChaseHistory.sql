CREATE TABLE [dbo].[tblSessionChaseHistory]
(
[SessionChaseHistory_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NOT NULL,
[Session_PK] [bigint] NOT NULL,
[ChaseStatus_PK] [bigint] NOT NULL,
[UpdateDate] [datetime] NOT NULL,
[UpdateUser_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSessionChaseHistory] ADD CONSTRAINT [PK_tblSessionChaseHistory] PRIMARY KEY CLUSTERED  ([SessionChaseHistory_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Session_PK] ON [dbo].[tblSessionChaseHistory] ([Session_PK]) INCLUDE ([ChaseStatus_PK], [Suspect_PK]) ON [PRIMARY]
GO
