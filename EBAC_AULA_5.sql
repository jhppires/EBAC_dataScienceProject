---Oportunidade de crescimento para clientes

select	constru_bem_vendas_final.Ano,
		constru_bem_vendas_final.CodCliente,
		sum(distinct B.ValorPotencial) as ValorPotencial,
		sum(constru_bem_vendas_final.valor) as ValorVendas

into #temp_1 --tabela temporaria que so existe durante essa sessão de consulta

from constru_bem_vendas_final
inner	join constru_bem_potencial_final B
on		constru_bem_vendas_final.CodCliente = B.CodCliente
and		constru_bem_vendas_final.Ano = B.ano 
group	by constru_bem_vendas_final.Ano, constru_bem_vendas_final.CodCliente


select * from #temp_1

--Formatação dos dados 
select Ano,
			format(sum(ValorPotencial), '###,##0.00','pt-br') as ValorPotencial,
			format(sum(ValorVendas), '###,##0.00','pt-br') as ValorVendas,
			format(sum(ValorPotencial) - sum(ValorVendas), '###,##0.00','pt-br') as Oportunidade,
			abs(((sum(ValorVendas)/sum(ValorPotencial))*100)-100) [Oportunidade%]
from #temp_1
group by Ano
order by ano


--Dedução e Formatação dos dados
select Ano,
			round(abs(((sum(ValorVendas)/sum(ValorPotencial))*100)-100),2) as [Oportunidade%],
			round(abs(abs(((sum(ValorVendas)/sum(ValorPotencial))*100)-100)-100),2) as [Alcançado%]
from #temp_1
group by Ano
order by ano

--Entendendo a perda de clientes
--Slide 3

select *
from(
		select	Ano,
				Categoria,
				Valor
		from	constru_bem_vendas_final
		where mes<=8		
		) t
pivot (sum(Valor) for Categoria in ([X],[XTZ250],[XT660], [CB750])) p
order by ano

--Clientes quantidade
select Ano,
			count(distinct codcliente) as [#Clientes]
from constru_bem_vendas_final
where mes <= 8
group by Ano
order by ano

--Conquistar novos Clientes
--Drop Table #tmp_nc

select Ano,
			sum(Area_Comercial) as Area_Comercial,
			sum(Area_Hibrida) as Area_Hibrida,
			sum(Area_residencial) as Area_residencial,
			sum(Area_industrial) as Area_industrial,

			sum(Area_Comercial)+
			sum(Area_Hibrida)+
			sum(Area_residencial)+
			sum(Area_industrial) as AreaTotal,

			sum(ValorPotencial) as ValorVendasPotencial
into #tmp_nc
from constru_bem_potencial_final A
where not exists (	select	1
					from	constru_bem_vendas_final B
					where	A.CodCliente = B.CodCliente
					and		A.Ano = B.Ano)
group by Ano

select * from #tmp_nc

-- transformar em percentual
select * from #tmp_nc order by ano

select Ano, 
			Area_Comercial/AreaTotal*100 as [Area_Comercial%],
			Area_Hibrida/AreaTotal*100 as [Area_Hibrida%],
			Area_residencial/AreaTotal*100 as [Area_residencial%],
			Area_industrial/AreaTotal*100 as [Area_industrial%],
			ValorVendasPotencial
from		#tmp_nc order by ano

--total de Clientes
select A.ano, count( distinct codcliente ) as Qtde
from constru_bem_potencial_final A
where not exists (	select	1
					from	constru_bem_vendas_final B
					where	A.CodCliente = B.CodCliente
					and		A.Ano = B.Ano)
group by Ano
with rollup --linha com total

--Analise por cidade
--Ranking
select *
from	(
		select top 10
					Cidade, 
					sum(valor) as Valor
		from		constru_bem_vendas_final
		group		by Cidade
		order		by 2 desc
)x order by 2

--valor total das top10

select *
into #tmp_cidade
from	(
		select top 10
					Cidade, 
					sum(valor) as Valor
		from		constru_bem_vendas_final
		group		by Cidade
		order		by 2 desc
)x order by 2

select format(sum(Valor), '###,##0.00','pt-br') from #tmp_cidade

declare @total_top10 as float
select @total_top10 = SUM(valor) from #tmp_cidade
select round(@total_top10/sum(valor)*100,2) as Perc from constru_bem_vendas_final

select count(distinct codcliente) from constru_bem_vendas_final where cidade in (select cidade from #tmp_cidade)

--quanidade de transações
select count(codcliente) from constru_bem_vendas_final where cidade  in (select cidade from #tmp_cidade)

-- totla transações
select count (codcliente) from constru_bem_vendas_final

--Alternativa

With Clientes as
			(
				select CodCliente,
						produto
				from constru_bem_vendas_final
				group by produto, CodCliente
			)
			select	*
			into	#tmp_produto1
			from	Clientes
--Grafico de rosca
			select Categoria, sum(Valor) as Valor
			from	(select codcliente,
							count(codcliente) as Qtde
					from #tmp_produto1
					group by codcliente
					having count(codcliente) = 1) as X
			inner join constru_bem_vendas_final B
			on			x.CodCliente = B.CodCliente
			group by Categoria
			order by 1

--##

--Valor transacionado
	select sum(Valor) as Valor
				from	(select codcliente,
								count(codcliente) as Qtde
						from #tmp_produto1
						group by codcliente
						having count(codcliente) = 1) as X
				inner join constru_bem_vendas_final B
				on			x.CodCliente = B.CodCliente
				order by 1

	select distinct Produto
			from	(select codcliente,
							count(codcliente) as Qtde
					from #tmp_produto1
					group by codcliente
					having count(codcliente) = 1) as X
			inner join constru_bem_vendas_final B
			on x.CodCliente =  B.CodCLiente
