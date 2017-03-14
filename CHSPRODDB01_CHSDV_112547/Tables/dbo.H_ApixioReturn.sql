CREATE TABLE [dbo].[H_ApixioReturn]
(
[H_ApixioReturn_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApixioReturn_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ApixioReturn] ADD CONSTRAINT [PK_H_ApixioReturn] PRIMARY KEY CLUSTERED  ([H_ApixioReturn_RK]) ON [PRIMARY]
GO
