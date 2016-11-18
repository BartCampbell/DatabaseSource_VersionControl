CREATE TABLE [dbo].[HCCHierarchy]
(
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCOverride] [int] NULL,
[HCCHierarchyID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HCCHierarchy] ADD CONSTRAINT [PK_HCCHierarchy] PRIMARY KEY CLUSTERED  ([HCCHierarchyID]) ON [PRIMARY]
GO
