CREATE TABLE [ref].[FacilityType]
(
[FacilityTypeID] [int] NOT NULL IDENTITY(1, 1),
[FacilityTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FacilityType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[FacilityType] ADD CONSTRAINT [PK_FacilityType] PRIMARY KEY CLUSTERED  ([FacilityTypeID]) ON [PRIMARY]
GO
