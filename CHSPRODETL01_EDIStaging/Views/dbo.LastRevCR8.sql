SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCR8]
AS
select *
from [dbo].[CR8] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CR8] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
