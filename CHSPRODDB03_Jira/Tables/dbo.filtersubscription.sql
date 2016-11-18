CREATE TABLE [dbo].[filtersubscription]
(
[ID] [numeric] (18, 0) NOT NULL,
[FILTER_I_D] [numeric] (18, 0) NULL,
[USERNAME] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[groupname] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LAST_RUN] [datetime] NULL,
[EMAIL_ON_EMPTY] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[filtersubscription] ADD CONSTRAINT [PK_filtersubscription] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [subscrptn_group] ON [dbo].[filtersubscription] ([FILTER_I_D], [groupname]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [subscrpt_user] ON [dbo].[filtersubscription] ([FILTER_I_D], [USERNAME]) ON [PRIMARY]
GO
