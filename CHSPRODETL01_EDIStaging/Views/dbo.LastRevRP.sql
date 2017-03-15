SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevRP]
AS
select *
from [dbo].[RP] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[RP] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
