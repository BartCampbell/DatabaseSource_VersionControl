CREATE TABLE [dbo].[tblUserZipCode]
(
[User_PK] [int] NOT NULL,
[ZipCode_PK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserZipCode] ADD CONSTRAINT [PK_tblUserZipCode] PRIMARY KEY CLUSTERED  ([User_PK], [ZipCode_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
