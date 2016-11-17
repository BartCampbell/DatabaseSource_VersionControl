CREATE TABLE [dbo].[H_Provider]
(
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Provider_BK] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Provider] ADD CONSTRAINT [PK_H_Provider] PRIMARY KEY CLUSTERED  ([H_Provider_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
