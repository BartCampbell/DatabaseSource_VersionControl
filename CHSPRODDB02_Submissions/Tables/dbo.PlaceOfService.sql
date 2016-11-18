CREATE TABLE [dbo].[PlaceOfService]
(
[POSCode] [smallint] NULL,
[POSName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PlaceOfService] ADD CONSTRAINT [PK_PlaceOfService] PRIMARY KEY CLUSTERED  ([POSID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
