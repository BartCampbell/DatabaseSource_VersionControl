SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLUI]
AS
select *
from [dbo].[LUI] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LUI] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
