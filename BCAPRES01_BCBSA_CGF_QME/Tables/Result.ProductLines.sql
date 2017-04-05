CREATE TABLE [Result].[ProductLines]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[ProductLines] ADD CONSTRAINT [PK_Result_ProductLines] PRIMARY KEY CLUSTERED  ([ProductLineID]) ON [PRIMARY]
GO
