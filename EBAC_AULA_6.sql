--Aula 6


create view [dbo].[vw_Potencial]

as

select	A.codcliente, A.Ano, A.Area_Comercial, A.Area_Hibrida, A.Area_Residencial,A.Area_Industrial, ValorPotencial, sum(valor) as ValorVendas

from	constru_bem_potencial_final A
left	join constru_bem_vendas_final B
on		A.codcliente	= B.codcliente
and		A.ano			= B.ano
group	by A.codcliente, A.Ano, A.Area_Comercial, A.Area_Hibrida, A.Area_Residencial, A.Area_Industrial, ValorPotencial
GO

select * from vw_Potencial