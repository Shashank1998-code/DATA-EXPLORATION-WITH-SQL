Select * From PORTFOLIO_PROJECT..CovidDeaths order by 3,4;

-- Select Data to be used
Select location,date,total_cases,new_cases,total_deaths,population 
From PORTFOLIO_PROJECT..CovidDeaths;


-- Total cases vs Total Deaths

-- Gives a rough estimate of death if covid is contracted

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PORTFOLIO_PROJECT..CovidDeaths;

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PORTFOLIO_PROJECT..CovidDeaths where location like '%states%';

-- Total cases vs Population
-- Shows the percentage of the population that contracted Covid 

Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From PORTFOLIO_PROJECT..CovidDeaths 
--where location like '%states%';

-- Highest Infection Rate compared with total population

Select location,MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as CovidPercentage
From PORTFOLIO_PROJECT..CovidDeaths 
Group by location,population
Order by CovidPercentage DESC,

-- Show countries with highest death count per population

Select location, MAX(cast(Total_deaths as int)) as HighestDeathCount
From PORTFOLIO_PROJECT..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc;

-- Highest Death Count by continents

Select continent, MAX(cast(Total_deaths as int)) as HighestDeathCount
From PORTFOLIO_PROJECT..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc;

-- Global Numbers

Select date,SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PORTFOLIO_PROJECT..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Global death percentage

Select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PORTFOLIO_PROJECT..CovidDeaths
where continent is not null
order by 1,2

Select * From PORTFOLIO_PROJECT..CovidVaccinations ;

-- Total Population vs Total Vaccinations
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
From PORTFOLIO_PROJECT..CovidDeaths dea
Join PORTFOLIO_PROJECT..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null

-- Rolling count of vaccinations

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingCountofPeopleVaccinated
From PORTFOLIO_PROJECT..CovidDeaths dea
Join PORTFOLIO_PROJECT..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountofPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date)
as RollingCountofPeopleVaccinated
From PORTFOLIO_PROJECT..CovidDeaths dea
Join PORTFOLIO_PROJECT..CovidVaccinations vac
on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
)
Select *,(RollingCountofPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

-- Creating views to store data for visualizations

Create View PercentageVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PORTFOLIO_PROJECT..CovidDeaths dea
Join PORTFOLIO_PROJECT..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * from PercentageVaccinated

