CREATE TABLE [dbo].[ChartIntakeMapping]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[Chart_File_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateReceived] [datetime] NULL CONSTRAINT [DF_ChartIntakeMapping_DateReceived] DEFAULT (getdate()),
[Suspect_PK] [int] NULL,
[IsProcessed] [bit] NULL CONSTRAINT [DF_ChartIntakeMapping_IsProcessed] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartIntakeMapping] ADD CONSTRAINT [PK_ChartIntakeMapping] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
