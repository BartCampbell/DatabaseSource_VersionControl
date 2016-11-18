CREATE TABLE [dbo].[journalentry]
(
[entry_id] [numeric] (19, 0) NOT NULL IDENTITY(1, 1),
[journal_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[creationdate] [datetime] NULL,
[type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[message] [nvarchar] (2047) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[journalentry] ADD CONSTRAINT [PK__journale__810FDCE14F376DBF] PRIMARY KEY CLUSTERED  ([entry_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [j_creationdate_idx] ON [dbo].[journalentry] ([creationdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [j_j_name_idx] ON [dbo].[journalentry] ([journal_name]) ON [PRIMARY]
GO
