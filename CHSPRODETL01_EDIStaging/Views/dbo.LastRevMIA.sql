SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevMIA]
AS
select *
from [dbo].[MIA] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[MIA] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
