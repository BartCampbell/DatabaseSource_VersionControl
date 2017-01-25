CREATE TABLE [Provider].[Specialties]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitSeed] [tinyint] NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [tinyint] NOT NULL CONSTRAINT [DF_Specialties_Priority] DEFAULT ((255)),
[SpecialtyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Specialties_SpecialtyGuid] DEFAULT (newid()),
[SpecialtyID] [smallint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Provider].[Specialties] ADD CONSTRAINT [CK_Specialties_BitSeed] CHECK (([BitSeed] IS NULL OR [BitSeed]>=(0) AND [BitSeed]<=(62)))
GO
ALTER TABLE [Provider].[Specialties] ADD CONSTRAINT [PK_Specialties] PRIMARY KEY CLUSTERED  ([SpecialtyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Specialties_Abbrev] ON [Provider].[Specialties] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Specialties_BitSeed] ON [Provider].[Specialties] ([BitSeed]) WHERE ([BitSeed] IS NOT NULL) WITH (FILLFACTOR=95) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Specialties_SpecialtyGuid] ON [Provider].[Specialties] ([SpecialtyGuid]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Limit on the bit seed due to data type (Can move to a max of 60 by changing int to bigint in BitValue calculation)', 'SCHEMA', N'Provider', 'TABLE', N'Specialties', 'CONSTRAINT', N'CK_Specialties_BitSeed'
GO
