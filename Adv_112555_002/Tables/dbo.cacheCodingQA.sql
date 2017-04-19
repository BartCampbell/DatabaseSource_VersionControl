CREATE TABLE [dbo].[cacheCodingQA]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[SortOrder] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxCacheCodingQA] ON [dbo].[cacheCodingQA] ([User_PK], [Suspect_PK]) ON [PRIMARY]
GO
