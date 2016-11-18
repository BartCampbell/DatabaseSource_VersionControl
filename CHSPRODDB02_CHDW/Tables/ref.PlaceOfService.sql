CREATE TABLE [ref].[PlaceOfService]
(
[POSCode] [smallint] NULL,
[POSName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[PlaceOfService] ADD CONSTRAINT [PK_PlaceOfService] PRIMARY KEY CLUSTERED  ([POSID]) ON [PRIMARY]
GO
