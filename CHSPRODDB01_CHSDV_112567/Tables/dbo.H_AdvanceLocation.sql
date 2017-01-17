CREATE TABLE [dbo].[H_AdvanceLocation]
(
[H_AdvanceLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdvanceLocation_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientAdvanceLocationID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_AdvanceLocation] ADD CONSTRAINT [PK_H_AdvanceLocation] PRIMARY KEY CLUSTERED  ([H_AdvanceLocation_RK]) ON [PRIMARY]
GO
