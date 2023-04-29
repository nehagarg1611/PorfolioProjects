select * 
from PortfolioProject..[covid deaths]
order by 3,4

--select * 
--from PortfolioProject..[covid vaccination]
--order by 3,4

--select data that we are going to be using
select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..[covid deaths]
order by 1,2


--looking at total cases vs total deaths
--shows likelyhood of dyng if you ontract covid in your country
select Location,date,total_cases,total_deaths,(CAST(Total_Deaths AS decimal) / CAST(Total_Cases AS decimal)) * 100 AS Death_Percentage
from PortfolioProject..[covid deaths]
where location like 'India'
order by 1,2

--looking at total cases vs population
select Location,date,total_cases,population,(CAST(total_cases AS decimal) / CAST(population AS decimal)) * 100 AS infectedPercentage
from PortfolioProject..[covid deaths]
where location like 'India'
order by 1,2


--looking at countries with highest infection rate compared to population
select Location,Max(total_cases) as highestInfectionCount,population,max((CAST(total_cases AS decimal) / CAST(population AS decimal))) * 100 AS infectedPercentage
From PortfolioProject..[covid deaths]
--where location like 'India'
Group by location,population
order by infectedPercentage desc

--showing countries with highest death count
select Location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc

--let's break things down by continent
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is  null
group by location
order by TotalDeathCount desc

--showing the continent with highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
       CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(new_deaths) / SUM(new_cases) * 100 END AS deathPercentage
FROM PortfolioProject..[covid deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases

--global numbers 2
SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
       CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(new_deaths) / SUM(new_cases) * 100 END AS deathPercentage
FROM PortfolioProject..[covid deaths]
WHERE continent IS NOT NULL

ORDER BY 1,2

--covid vaccination
--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as decimal )) over
(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
--,(rollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join  PortfolioProject..[covid vaccination] vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsVac (continent,location,date,population,new_vaccinations,rollingPeopleVaccination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as decimal )) over
(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
--,(rollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join  PortfolioProject..[covid vaccination] vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccination/population)*100
from popvsVac

--temp table
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccination numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as decimal )) over
(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
--,(rollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join  PortfolioProject..[covid vaccination] vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(rollingPeopleVaccination/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualisation
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as decimal )) over
(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
--,(rollingPeopleVaccination/population)*100
from PortfolioProject..[covid deaths] dea
join  PortfolioProject..[covid vaccination] vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3