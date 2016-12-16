CREATE TABLE [dbo].[tblZoneZipcode]
(
[Zone_PK] [tinyint] NOT NULL,
[ZipCode_PK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblZoneZipcode] ADD CONSTRAINT [PK_tblZoneZipcode] PRIMARY KEY CLUSTERED  ([Zone_PK], [ZipCode_PK]) ON [PRIMARY]
GO
