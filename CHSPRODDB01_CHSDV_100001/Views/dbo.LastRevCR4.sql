SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCR4]
AS
select *
from [dbo].[CR4] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CR4] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
