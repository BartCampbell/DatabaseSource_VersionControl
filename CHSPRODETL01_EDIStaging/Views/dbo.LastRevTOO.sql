SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevTOO]
AS
select *
from [dbo].[TOO] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[TOO] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
