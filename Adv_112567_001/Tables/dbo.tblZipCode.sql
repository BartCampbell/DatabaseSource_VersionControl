CREATE TABLE [dbo].[tblZipCode]
(
[ZipCode_PK] [int] NOT NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[County] [varchar] (40) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblZipCode] ADD CONSTRAINT [PK_tblZipCodes_1] PRIMARY KEY CLUSTERED  ([ZipCode_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblZipCodes] ON [dbo].[tblZipCode] ([ZipCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
