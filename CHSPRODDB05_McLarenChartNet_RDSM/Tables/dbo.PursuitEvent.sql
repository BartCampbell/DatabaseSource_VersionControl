CREATE TABLE [dbo].[PursuitEvent]
(
[PursuitEventTrackingNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDate] [datetime] NOT NULL,
[CustomerProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderSiteID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PriorityOrder] [int] NOT NULL,
[PursuitCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [PK_PursuitEvent] PRIMARY KEY CLUSTERED  ([PursuitEventTrackingNumber], [HEDISMeasure], [EventDate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PursuitEvent] ON [dbo].[PursuitEvent] ([CustomerMemberID], [CustomerProviderID], [ProviderSiteID], [HEDISMeasure], [EventDate]) ON [PRIMARY]
GO
