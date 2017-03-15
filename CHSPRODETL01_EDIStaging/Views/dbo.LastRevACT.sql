SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevACT]
AS
select *
from [dbo].[ACT] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[ACT] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
