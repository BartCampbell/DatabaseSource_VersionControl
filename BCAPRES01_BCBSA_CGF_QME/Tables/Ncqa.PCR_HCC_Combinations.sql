CREATE TABLE [Ncqa].[PCR_HCC_Combinations]
(
[HClinCond] [smallint] NOT NULL,
[HCombo] [smallint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[OptionNbr] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_HCC_Combinations] ADD CONSTRAINT [PK_PCR_HCC_Combinations] PRIMARY KEY CLUSTERED  ([MeasureSetID], [HClinCond], [HCombo], [OptionNbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCR_HCC_Combinations] ON [Ncqa].[PCR_HCC_Combinations] ([MeasureSetID], [HCombo], [OptionNbr]) INCLUDE ([HClinCond]) ON [PRIMARY]
GO
