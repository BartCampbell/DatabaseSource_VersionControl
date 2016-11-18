CREATE TABLE [ref].[HEDISProductRollup]
(
[HEDISProductRollupID] [int] NOT NULL IDENTITY(1, 1),
[ProductRollupID] [int] NOT NULL,
[ProductID] [int] NOT NULL,
[ProductOrder] [int] NOT NULL,
[ProductDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[HEDISProductRollup] ADD CONSTRAINT [PK_HEDISProductRollup] PRIMARY KEY CLUSTERED  ([HEDISProductRollupID]) ON [PRIMARY]
GO
