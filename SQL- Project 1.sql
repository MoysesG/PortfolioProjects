
--Explore The Data

select * from [PortfolioProjects- Covid 19].dbo.CovidDeaths

select * from CovidVaccinations



--Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from covidDeaths
where location like '%States%'
order by 1,2

--Total Cases vs Population
-- Show what Percentage of Population got Covid

Select location, date,population, total_cases,  
 (NULLIF(CONVERT(float, total_cases), 0) /population) * 100 AS Percent_Population_Infected
from covidDeaths
order by 1,2

-- Countries With Highest Infection rate Compared to Population

Select location, population, max(total_cases) as highest_Infection_Count,  
 MAX((NULLIF(CONVERT(float, total_cases), 0) /population)) * 100 AS Percent_Population_Infected
from covidDeaths
group by location, population
order by Percent_Population_Infected desc

--showing Countries With Highest Death Count Per Population

Select location, max(cast(total_deaths as int)) as TotaldeathCount 
from  [PortfolioProjects- Covid 19].dbo.CovidDeaths 
where continent is not null
group by location
order by TotaldeathCount desc

--showing ontinent With Highest Death Count Per Population

Select continent, max(cast(total_deaths as int)) as TotaldeathCount 
from  [PortfolioProjects- Covid 19].dbo.CovidDeaths 
where continent is not null
group by continent
order by TotaldeathCount desc

--Global Numbers

Select date,SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_Death,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from  [PortfolioProjects- Covid 19].dbo.CovidDeaths
where Continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with Popvsvac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/population)*100 from Popvsvac

--Temp Table



create table #PercentPopulationVaccineted
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccineted
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccineted

-- Creating View to Store Data For Later Visualizations

create view PercentPopulationVaccineted as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccineted