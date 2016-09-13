CREATE TABLE [dbo].[tblAdjustment]
(
[RateYear] [smallint] NOT NULL,
[FFS_V12] [float] NOT NULL,
[FFS_V22] [float] NOT NULL,
[FFS_V21] [float] NOT NULL,
[FFS_FG] [float] NOT NULL,
[Coding_Intensity] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAdjustment] ADD CONSTRAINT [PK_tblAdjustment] PRIMARY KEY CLUSTERED  ([RateYear]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
