CREATE TABLE [dbo].[tblHEDIS_suspect]
(
[suspect_pk] [bigint] NOT NULL,
[measure_pk] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHEDIS_suspect] ADD CONSTRAINT [PK_tblHEDIS_suspect] PRIMARY KEY CLUSTERED  ([suspect_pk], [measure_pk]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
