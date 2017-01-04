CREATE TABLE [ref].[PointOfOrigin]
(
[PointOfOriginID] [int] NOT NULL IDENTITY(1, 1),
[PointOfOriginCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PointOfOrigin] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsNewBorn] [bit] NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[PointOfOrigin] ADD CONSTRAINT [PK_PointOfOrigin] PRIMARY KEY CLUSTERED  ([PointOfOriginID]) ON [PRIMARY]
GO
