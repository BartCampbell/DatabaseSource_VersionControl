CREATE TABLE [ref].[RxHCCHierarchy]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[HCCVersion] [int] NULL,
[HCCVersionYear] [int] NULL,
[CCType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCOverride] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[RxHCCHierarchy] ADD CONSTRAINT [UQ__RxHCCHie__360414FE009C32A5] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
