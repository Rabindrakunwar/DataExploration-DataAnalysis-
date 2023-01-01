--select * from PortfolioProject..CovidDeaths
--select * from PortfolioProject..CovidVaccinations

select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths
where continent is not null
order by 1,2

--Total Cases VS Total Deaths
--likelihood of dying in respective country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage,population 
from CovidDeaths
where continent is not null
and location like '%Nepal%' 
order by 1,2

--Total Cases VS Population
--shows what popn suffer from covid

select location,date,total_cases,total_deaths,(total_cases/population)*100 as CovidPercentage,population 
from CovidDeaths
where location like '%Nepal%'
order by 1,2


--Looking at country with highest percentage rate

select location,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PopnPercentage,population 
from CovidDeaths
where continent is not null
--where location like '%Nepal%'
group by location,population
order by PopnPercentage desc

--showing countries with highest deathcount per population
select location,MAX(cast(total_deaths as int)) as DeathCount,population 
from CovidDeaths
where continent is not null
group by location,population
order by DeathCount DESC

--By Continent
select location,MAX(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is null
group by location
order by DeathCount DESC


select continent,MAX(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by continent
order by DeathCount DESC


--Showing Continent with the highest deathcount per population


select continent,MAX(cast(total_deaths as int)) as DeathCount
from CovidDeaths
where continent is not null
group by continent
order by DeathCount DESC

--GLobal Numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/ SUM(new_cases) *100
from CovidDeaths
where continent is not null
group by date
--and location like '%Nepal%' 
order by 1,2

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/ SUM(new_cases) *100
from CovidDeaths
where continent is not null
--group by date
--and location like '%Nepal%' 
order by 1,2

--Join
--looking at total vaccination vs population
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as (Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric


)


Insert Into #PercentPopulationVaccinated 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--VIEW CREATION

create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated