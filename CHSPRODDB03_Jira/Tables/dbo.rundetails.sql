CREATE TABLE [dbo].[rundetails]
(
[ID] [numeric] (18, 0) NOT NULL,
[JOB_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[START_TIME] [datetime] NULL,
[RUN_DURATION] [numeric] (18, 0) NULL,
[RUN_OUTCOME] [nchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[INFO_MESSAGE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rundetails] ADD CONSTRAINT [PK_rundetails] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rundetails_jobid_idx] ON [dbo].[rundetails] ([JOB_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rundetails_starttime_idx] ON [dbo].[rundetails] ([START_TIME]) ON [PRIMARY]
GO
