CREATE TABLE [dbo].[issuelink]
(
[ID] [numeric] (18, 0) NOT NULL,
[LINKTYPE] [numeric] (18, 0) NULL,
[SOURCE] [numeric] (18, 0) NULL,
[DESTINATION] [numeric] (18, 0) NULL,
[SEQUENCE] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issuelink] ADD CONSTRAINT [PK_issuelink] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issuelink_dest] ON [dbo].[issuelink] ([DESTINATION]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issuelink_type] ON [dbo].[issuelink] ([LINKTYPE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issuelink_src] ON [dbo].[issuelink] ([SOURCE]) ON [PRIMARY]
GO
