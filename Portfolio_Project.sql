Select *
From ProjectPortfolio..CovidVaccinations
Where continent is not null
Order By 3,4


--Select *
--From ProjectPortfolio..CovidDeath
--Order By 3,4

--Select the Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From ProjectPortfolio..CovidDeath
Where continent is not null
Order by 1,2

-- Lokking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid 19 in your Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From ProjectPortfolio..CovidDeath
Where Location like '%states%'
and continent is not null
Order by 1,2

--Looking at the Total cases vs Population
-- Shows what percentage of population that got Covid-19
Select Location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From ProjectPortfolio..CovidDeath
--Where Location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compare to Poplation
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From ProjectPortfolio..CovidDeath
--Where Location like '%states%'
Group by Location, population 
Order by PercentPopulationInfected Desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeath
Where continent is not null
--Where Location like '%states%'
Group by location
Order by TotalDeathCount Desc

-- LET'S BREAK IT DOWN BY CONTINENT
--Showing Countries with Highest Death Count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeath
Where continent is not null
--Where Location like '%states%'
Group by continent
Order by TotalDeathCount Desc

--GLOBAL NUMBERS


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
From ProjectPortfolio..CovidDeath
--Where Location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Looking  at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeath dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--and vac.new_vaccinations is not null
Order by 2,3

--USE CTE
With PopvsVac (COntinent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeath dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (225),
Location nvarchar (225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeath dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store date for later visualization

Create View PercentPopulationVaccinate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeath dea
Join ProjectPortfolio..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--and vac.new_vaccinations is not null
--Order by 2,3


Create View WorldView as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeath
Where continent is not null
--Where Location like '%states%'
Group by continent
--Order by TotalDeathCount Desc