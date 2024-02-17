
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinationsCSV
--order by 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--looking at total_cases vs total_deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at the total cases vs population
-- shows what percentage of population got covid

Select location, date, population,total_cases, (cast(total_cases as float)/cast(population as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compaired to population

Select location, population, MAX(total_cases) as Highestinfectioncount, MAX(cast (total_cases as float)/cast(population as float))*100 as Percentpopulationinfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by Percentpopulationinfected desc

--showing the countries with highest death count perpopulation

Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathcount desc

--lets break things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathcount desc

-- by continent

--showing the continent with the highest deathcount per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathcount desc

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, nullif(sum(new_deaths),0)/nullif(sum(New_Cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2
--looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsCSV vac
    on dea.location =vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--use CTE

with popvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsCSV vac
    on dea.location =vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From popvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsCSV vac
    on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--creating view to store data later visualizations


create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinationsCSV vac
    on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated