select * from dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from dbo.CovidVaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths where continent is not null order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentase
from dbo.CovidDeaths where location like '%indonesia%'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as CasePercentase
from dbo.CovidDeaths
--where location like '%indonesia%'
order by 1,2


--negara terpapar tertinggi berdasarkan populasi
select location, population, MAX(total_cases) as highestInfection, MAX((total_cases/population))*100 as PersentasePopulasiTerpapar
from dbo.CovidDeaths
--where location like '%indonesia%'
group by location, population
order by PersentasePopulasiTerpapar desc

--negara dengan kematian tertinggi
select location, max(cast(total_deaths as int)) as KematianTertinggi
from dbo.CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by location
order by KematianTertinggi desc


select continent, max(cast(total_deaths as int)) as KematianTertinggi
from dbo.CovidDeaths
--where location like '%indonesia%'
where continent is not null
group by continent
order by KematianTertinggi desc



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over
(partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--ga bisa
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) over
(partition by dea.Location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) over
(partition by dea.Location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--create view for visualization
--drop view PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over
(partition by dea.Location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated

