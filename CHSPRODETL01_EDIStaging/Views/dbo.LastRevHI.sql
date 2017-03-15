SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevHI]
AS
select *
from [dbo].[HI] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[HI] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
