CREATE TABLE [dbo].[Comm_HCCHierarchy]
(
[HCCHierarchyID] [int] NOT NULL IDENTITY(1, 1),
[HCCVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCCVersionYear] [int] NULL,
[CCType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCOverride] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comm_HCCHierarchy] ADD CONSTRAINT [UQ__Comm_HCC__C0D22D4A105A8D53] UNIQUE NONCLUSTERED  ([HCCHierarchyID]) ON [PRIMARY]
GO
