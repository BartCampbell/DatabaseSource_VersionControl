CREATE TABLE [dbo].[tblEMR_Type]
(
[EMR_Type_PK] [smallint] NOT NULL IDENTITY(1, 1),
[EMR_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[IsNew] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEMR_Type] ADD CONSTRAINT [PK_tblEMR_Type] PRIMARY KEY CLUSTERED  ([EMR_Type_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
