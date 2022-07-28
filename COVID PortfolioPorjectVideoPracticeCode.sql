Select *
From PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations 
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
order by 1,2

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population

Select Location, date, total_cases,Population, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--Where location like '%states'
Group by Location, Population
order by PercentPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
Where continent is not null
Group by continent 
order by TotalDeathCount desc

--Showing continent with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc




--GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM (cast(new_deaths as int))/SUM(New_cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
where continent is not null
Group by date 
order by 1,2

--TEMP TABLE

DROP TABLE if exists #PercentPoplulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date=vac.date 
   where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

--Creating View to store data for later visualizations

Create View  PercentPoluationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date=vac.date 
   where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated 
