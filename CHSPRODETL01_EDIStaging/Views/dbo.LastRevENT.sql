SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevENT]
AS
select *
from [dbo].[ENT] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[ENT] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
