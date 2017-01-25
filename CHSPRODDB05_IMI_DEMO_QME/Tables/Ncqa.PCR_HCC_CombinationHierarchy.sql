CREATE TABLE [Ncqa].[PCR_HCC_CombinationHierarchy]
(
[ChildHCombo] [smallint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[ParentHCombo] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_HCC_CombinationHierarchy] ADD CONSTRAINT [PK_PCR_HCC_CombinationHierarchy] PRIMARY KEY CLUSTERED  ([MeasureSetID], [ChildHCombo], [ParentHCombo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'Ncqa', 'TABLE', N'PCR_HCC_CombinationHierarchy', NULL, NULL
GO
