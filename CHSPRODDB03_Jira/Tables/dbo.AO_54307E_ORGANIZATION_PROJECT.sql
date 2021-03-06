CREATE TABLE [dbo].[AO_54307E_ORGANIZATION_PROJECT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ORGANIZATION_ID] [int] NULL,
[PROJECT_ID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_54307E_ORGANIZATION_PROJECT] ADD CONSTRAINT [pk_AO_54307E_ORGANIZATION_PROJECT_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_54307e_org1427239366] ON [dbo].[AO_54307E_ORGANIZATION_PROJECT] ([ORGANIZATION_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_54307e_org1226133886] ON [dbo].[AO_54307E_ORGANIZATION_PROJECT] ([PROJECT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_54307E_ORGANIZATION_PROJECT] ADD CONSTRAINT [fk_ao_54307e_organization_project_organization_id] FOREIGN KEY ([ORGANIZATION_ID]) REFERENCES [dbo].[AO_54307E_ORGANIZATION] ([ID])
GO
