Select * from [Covid DB]..CovidDeaths$ order by 3,4

--Select * from [Covid DB]..CovidVaccinations$ order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
from [Covid DB]..CovidDeaths$
order by 1,2

--Total cases Vs Total deaths
--depicts the likelihood of dying if you get infected
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as "Death Percentage"
from [Covid DB]..CovidDeaths$
where location like '%Asia%'
order by 1,2

--Total cases vs population
--Shows what % of population got covid
Select Location,date,total_cases,population, (total_cases/population)*100 as "Infection_rate"
from [Covid DB]..CovidDeaths$
--where location like '%Asia%'
order by 1,2

--countries with highest infection rate
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Infected_rate
from [Covid DB]..CovidDeaths$
group by location,population
order by Infected_rate desc

--countries with highest death count broken down into continents
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Covid DB]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers by date
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
Death_Percentage
from [Covid DB]..CovidDeaths$
where continent is not null
group by date
order by date

--overal global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
Death_Percentage
from [Covid DB]..CovidDeaths$
where continent is not null

--join the 2 tables
--Select * from [Covid DB]..CovidVaccinations$ dea
--join [Covid DB]..CovidDeaths$ vac
--on dea.location=vac.location and dea.date=vac.date

--total pouplations vs vaccinated
select 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
from [Covid DB]..CovidDeaths$ dea
join [Covid DB]..CovidVaccinations$ vac
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--using CTE
with Pop_vs_Vac (continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
as
(
select 
    dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER
	(Partition by dea.Location Order by dea.Location,dea.date) as Rolling_people_vaccinated
from [Covid DB]..CovidDeaths$ dea
join [Covid DB]..CovidVaccinations$ vac
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
)
select *,(Rolling_people_vaccinated/population)*100
from Pop_vs_Vac



--DROP table if exists #PercentPopulationVaccinated
--TEMP table
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select 
    dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER
	(Partition by dea.Location Order by dea.Location,dea.date) as Rolling_people_vaccinated
from [Covid DB]..CovidDeaths$ dea
join [Covid DB]..CovidVaccinations$ vac
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null

select *,(Rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER
	(Partition by dea.Location Order by dea.Location,dea.date) as Rolling_people_vaccinated
from [Covid DB]..CovidDeaths$ dea
join [Covid DB]..CovidVaccinations$ vac
    on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


