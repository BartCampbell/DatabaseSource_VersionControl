SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevIMM]
AS
select *
from [dbo].[IMM] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[IMM] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
