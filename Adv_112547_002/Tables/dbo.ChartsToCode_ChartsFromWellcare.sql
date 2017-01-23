CREATE TABLE [dbo].[ChartsToCode_ChartsFromWellcare]
(
[Chart ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mbr ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member First] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Last] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [datetime] NULL,
[LOB] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChartsToCode_ChartsFromWellcare] ADD CONSTRAINT [PK_ChartsToCode_ChartsFromWellcare] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
