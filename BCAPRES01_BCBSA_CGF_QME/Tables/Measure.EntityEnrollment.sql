CREATE TABLE [Measure].[EntityEnrollment]
(
[EntityID] [int] NOT NULL,
[IgnoreClass] [bit] NOT NULL CONSTRAINT [DF_EntityEnrollment_IgnoreClass] DEFAULT ((0)),
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_EntityEnrollment_IsEnabled] DEFAULT ((1)),
[MeasEnrollID] [int] NOT NULL,
[OptionNbr] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[EntityEnrollment] ADD CONSTRAINT [PK_MeasurePopulationEnrollment] PRIMARY KEY CLUSTERED  ([EntityID], [MeasEnrollID], [OptionNbr]) ON [PRIMARY]
GO
