create database Covid_Project;

use covid_project;

show tables;

drop table coviddeaths;
drop table covidvaccination;

#1.select data that we are going to use

select * from coviddeaths;
select * from covidvaccination ;

select location, `date`, total_cases, new_cases, total_deaths, population  from coviddeaths;

#2.Looking total_cases vs total_deaths

select location, `date`, total_cases, total_deaths,
(total_deaths/total_cases)*100 as Deaths_Percentage from coviddeaths
where location = 'india';

#3. Looking total_cases vs population

select location, `date`, total_cases, population ,
(total_cases/population)*100 as Case_percentage from coviddeaths
where location = 'india';

#4. Looking at countries with highest infection rate compare to population

select location, max(total_cases) as High_Infection_rate, population ,
max(total_cases/population)*100 as Population_infected_percentage from coviddeaths
group by location , population order by max(total_cases/population)*100 desc;


#4. Showing countries with high death count per population

select location, max(total_deaths) as Total_Death_count from coviddeaths
where continent is not null
group by location 
order by Total_Death_count desc;

#5. Showing continent with high death count per population

select continent , max(total_deaths) as Total_Death_count from coviddeaths
where continent is not null
group by continent  
order by Total_Death_count desc;


#6. Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, 
sum(cast(new_deaths as signed))/sum(new_cases)*100 as Death_percentage from coviddeaths
where continent is not null 
#group by `date`
order by 1,2;

#7. Looking total population vs vaccinations

select dea.continent, dea.`date`, dea.location, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.`date`) as Rolling_People_Vaccinated
#,(Rolling_People_Vaccinated/dea.population)*100 AS Vaccination_Percentage
from coviddeaths as dea join covidvaccination as vac 
on dea.location = vac.location and dea.`date` = vac.`date`
where dea.continent is not null;

#8. Use CTE

with popvsvac (continent,`date`,location,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
select dea.continent, dea.`date`, dea.location, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.`date`) as Rolling_People_Vaccinated
from coviddeaths as dea join covidvaccination as vac 
on dea.location = vac.location and dea.`date` = vac.`date`
where dea.continent is not null
)


select *, (Rolling_People_Vaccinated/population)*100 as Percentage_of_vaccinated from popvsvac;


#9. Temp Table
drop table populationpercentagevaccinated;
create table populationpercentagevaccinated
(
continent varchar(255),
location varchar(255),
`date` datetime,
population int,
new_vaccinations int,
Rolling_People_Vaccinated int
);

insert into populationpercentagevaccinated
select dea.continent, dea.`date`, dea.location, dea.population , vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.`date`) as Rolling_People_Vaccinated
#(Rolling_People_Vaccinated/population)*100
from coviddeaths as dea join covidvaccination as vac 
on dea.location = vac.location and dea.`date` = vac.`date`
where dea.continent is not null;

create view deathpercetage as
select sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, 
sum(cast(new_deaths as signed))/sum(new_cases)*100 as Death_percentage from coviddeaths
where continent is not null 
#group by `date`
order by 1,2;