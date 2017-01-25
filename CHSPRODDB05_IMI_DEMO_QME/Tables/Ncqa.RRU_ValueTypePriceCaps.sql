CREATE TABLE [Ncqa].[RRU_ValueTypePriceCaps]
(
[FuncPrefix] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RRU_ValueTypePriceCaps_FuncPrefix] DEFAULT (''),
[FuncSuffix] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RRU_ValueTypePriceCaps_FuncSuffix] DEFAULT (''),
[MeasureSetID] [int] NOT NULL,
[PriceCap] [decimal] (18, 4) NOT NULL,
[RRUValTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_ValueTypePriceCaps] ADD CONSTRAINT [PK_Ncqa_RRU_ValueTypePriceCaps] PRIMARY KEY CLUSTERED  ([MeasureSetID], [RRUValTypeID]) ON [PRIMARY]
GO
