# Project Citizen Ruru
### Brief introduction
This project is a pilot research conducted to better understand the distribution of ruru/morepork in the Greater Wellington region and improve monitoring efforts of this species. We conducted a citizen science project named Citizen Ruru, which involved the Wellington community to undertake 1-hour surveys and submit them through i-Naturalist or our Google forms. 

#### Programmes and software used
In this project, R language was written in Rstudio to run simulations for modelling a point process and poisson distribution of the ruru/morepork call times. In addition, ArcGIS Pro was used to visualise the data using maps, for example, the observation data obtained from our i-Naturalist project (Citizen Ruru). Python code was written in Jupyter Notebook to clean and process the observation data before the data is used in ArcGIS Pro.

### Key research questions
- What is the abundance and dsitribution of ruru/morepork throughout Wellington?
- Is a 1-hour survey held at 9-10pm methodology capable of providing sufficient and reliable data to understand the distribution of ruru?
- How do different data collection methodology (fully structured, partially structured, and unstructured) compare with each other?
- What further improvements need to be made in future monitoring of the distribution of ruru?

#### Set Up
1. Ensure that you have installed RStudio (version 4.3.2 or later), either Jupyter Notebook or software that can run Python language and ArcGIS Pro (version 3.0.2 or later).
2. Download "data".
3. Download the R and ipynb files and ensure they are located in the same folder as the downloaded "data" folder.
4. Run the code.

#### About the data files
- In the data folder, the "ruru_obs.csv"  file contains data about the observations exported from the Citizen Ruru i-Naturalist project page.
- After processing the raw data in "ruru_obs.csv" with the code from "data_processing.ipynb", it is saved as "surveyed_obs_cleaned.csv" in the "data" folder. This saved file has its data cleaned so it can be used in ArcGIS Pro.
