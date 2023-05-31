Select * 
From PortfolioProject1.dbo.CovidDeaths
Order by 3,4

--Select * 
--From PortfolioProject1.dbo.CovidVaccinations
--Order by 3,4

--Select Data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
where Location like 'Afghanistan'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percent of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulation
From PortfolioProject1.dbo.CovidDeaths
--where Location like 'Afghanistan'
order by 1,2

--Looking at Countries with Highest Infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
--where Location like 'Afghanistan'
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1.dbo.CovidDeaths
--where Location like 'Afghanistan'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break things down by Continent
--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1.dbo.CovidDeaths
--where Location like 'Afghanistan'
where continent is not null
Group by Continent
order by TotalDeathCount desc

--Global Numbers
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
--where Location like 'Afghanistan'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(260),
Location nvarchar(260),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated