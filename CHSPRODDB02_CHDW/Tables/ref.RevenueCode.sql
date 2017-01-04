CREATE TABLE [ref].[RevenueCode]
(
[RevenueCodeID] [int] NOT NULL IDENTITY(1, 1),
[RevenueCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RevenueCodeDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[RevenueCode] ADD CONSTRAINT [PK_RevenueCode] PRIMARY KEY CLUSTERED  ([RevenueCodeID]) ON [PRIMARY]
GO
