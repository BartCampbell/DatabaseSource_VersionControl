CREATE TABLE [dbo].[userpickerfilterrole]
(
[ID] [numeric] (18, 0) NOT NULL,
[USERPICKERFILTER] [numeric] (18, 0) NULL,
[PROJECTROLEID] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userpickerfilterrole] ADD CONSTRAINT [PK_userpickerfilterrole] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cf_userpickerfilterrole] ON [dbo].[userpickerfilterrole] ([USERPICKERFILTER]) ON [PRIMARY]
GO
