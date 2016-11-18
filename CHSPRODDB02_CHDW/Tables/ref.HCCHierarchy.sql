CREATE TABLE [ref].[HCCHierarchy]
(
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCOverride] [int] NULL,
[HCCHierarchyID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[HCCHierarchy] ADD CONSTRAINT [PK_HCCHierarchy] PRIMARY KEY CLUSTERED  ([HCCHierarchyID]) ON [PRIMARY]
GO
