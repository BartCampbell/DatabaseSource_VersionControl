CREATE TABLE [dbo].[tblMORDetailDmg]
(
[MORHeader_PK] [bigint] NOT NULL,
[Dmg_PK] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMORDetailDmg] ADD CONSTRAINT [PK_tblMORDetailDmg] PRIMARY KEY CLUSTERED  ([MORHeader_PK], [Dmg_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
