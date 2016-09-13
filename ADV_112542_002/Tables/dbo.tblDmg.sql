CREATE TABLE [dbo].[tblDmg]
(
[Dmg_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Dmg_Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMale] [bit] NULL,
[Age_Low] [tinyint] NULL,
[Age_High] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDmg] ADD CONSTRAINT [PK_tblDmg] PRIMARY KEY CLUSTERED  ([Dmg_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
