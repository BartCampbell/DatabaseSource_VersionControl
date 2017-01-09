CREATE TABLE [dbo].[tblZipCode]
(
[ZipCode_PK] [int] NOT NULL,
[ZipCode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblZipCode] ADD CONSTRAINT [PK_tblZipCodes_1] PRIMARY KEY CLUSTERED  ([ZipCode_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblZipCodes] ON [dbo].[tblZipCode] ([ZipCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
