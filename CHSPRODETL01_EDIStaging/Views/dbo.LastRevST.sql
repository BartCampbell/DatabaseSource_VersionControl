SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevST]
AS
select *
from [dbo].[ST] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[ST] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
