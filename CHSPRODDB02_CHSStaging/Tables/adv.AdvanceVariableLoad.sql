CREATE TABLE [adv].[AdvanceVariableLoad]
(
[VariableLoadKey] [int] NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__AdvanceVa__Creat__02DFA5DE] DEFAULT (getdate())
) ON [PRIMARY]
GO
