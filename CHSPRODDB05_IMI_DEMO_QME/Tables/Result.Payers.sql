CREATE TABLE [Result].[Payers]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PayerID] [smallint] NOT NULL,
[ProductClassID] [tinyint] NULL,
[ProductLineID] [smallint] NOT NULL,
[ProductTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[Payers] ADD CONSTRAINT [PK_Result_Payers] PRIMARY KEY CLUSTERED  ([PayerID], [ProductLineID]) ON [PRIMARY]
GO
