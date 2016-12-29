CREATE TABLE [dbo].[tblZone]
(
[Zone_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Zone_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblZone] ADD CONSTRAINT [PK_tblZone] PRIMARY KEY CLUSTERED  ([Zone_PK]) ON [PRIMARY]
GO
