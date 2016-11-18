CREATE TABLE [ref].[Comm_HCCHierarchy]
(
[HCCHierarchyID] [int] NOT NULL,
[HCCVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCCVersionYear] [int] NULL,
[CCType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCOverride] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[Comm_HCCHierarchy] ADD CONSTRAINT [PK_Comm_HCCHierarchy] PRIMARY KEY CLUSTERED  ([HCCHierarchyID]) ON [PRIMARY]
GO
