CREATE TABLE [dbo].[H_RAPS_Response]
(
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RAPS_Response_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_H_RAPS_Response_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_RAPS_Response] ADD CONSTRAINT [PK_H_RAPS_Response] PRIMARY KEY CLUSTERED  ([H_RAPS_Response_RK]) ON [PRIMARY]
GO
