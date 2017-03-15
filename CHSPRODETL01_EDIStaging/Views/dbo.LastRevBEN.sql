SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevBEN]
AS
select *
from [dbo].[BEN] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[BEN] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
