SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSBR]
AS
select *
from [dbo].[SBR] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SBR] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
