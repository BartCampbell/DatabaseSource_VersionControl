CREATE TABLE [dbo].[tblLocation]
(
[Location_PK] [tinyint] NOT NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLocation] ADD CONSTRAINT [PK_tblLocation] PRIMARY KEY CLUSTERED  ([Location_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
