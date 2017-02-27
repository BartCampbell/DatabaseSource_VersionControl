CREATE TABLE [dbo].[H_TRRVerbatim]
(
[H_TRRVerbatim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TRRVerbatim_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_TRRVerbatim] ADD CONSTRAINT [PK_H_TRRVerbatim] PRIMARY KEY CLUSTERED  ([H_TRRVerbatim_RK]) ON [PRIMARY]
GO
