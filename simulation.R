#### Poisson Distribution ####
# Simulate number of calls in  an  hour

# https://www.programmingr.com/examples/neat-tricks/sample-r-function/rpois-poisson-distribution/
# rpois( #obs, lambda=rate)
# rate: average events per period

# How many times is an owl likely to call between 9-10pm? 
# Assuming that an owl calls on average 6 times per hour.
rate <- 6 # average number of calls in an hour
n <- 100 # number of values/simulations to return
sim_calls <- rpois(n,rate)

# Create a histogram
hist(sim_calls, main = "Distribution of Owl Calls in One Hour",
     xlab = "Number of Calls", ylab = "Frequency", col = "skyblue", border = "black")


#### Simulate the owl call times ####
# Generate random times for owl calls between 9:00 PM and 10:00 PM
generate_owl_call_times <- function(lambda){
  start_time <- 0
  end_time <- 59
  
  # Generate random number of calls in an hour
  num_calls <- rpois(1, lambda = lambda)
  
  # Generate n (num_calls) random times at which each call occurs
  # runif: generate random values from a uniform distribution
  call_times <- sort(runif(num_calls, min = start_time, max = end_time))
  
  return(call_times)
}

# Define a function to convert decimal time to "HH:MM" format
convert_decimal_to_time <- function(decimal_time) {
  # Extract hours and minutes
  hours <- 21 #9PM
  minutes <- round(decimal_time)
  
  # Format the time
  ## if the number has fewer than two digits, it will be padded with leading 0 to make it two digits long.
  time_str <- sprintf("%02d:%02d", hours, minutes)
  
  return(time_str)
}


### TESTING
set.seed(123)
lambda <- 6
call_times <- generate_owl_call_times(lambda)
print(call_times)

# Convert times to "HH:MM" format
times_formatted <- sapply(call_times, convert_decimal_to_time)

# Print the formatted times
print(times_formatted)


#### Poisson Point Process ####
# Install and load the spatstat package
library(spatstat)
library(sf)
library(sp)
library(raster)
library(rstan)
library(tidyverse)
library(cowplot)

# SIMULATING a point pattern
# Here is a function which internally generate a point pattern based on our values of α, β and the dimensions of our study area. Note that the dim[1] and dim[2] have to be equal.
# The function returns a list of 3 objects:
# - The number of points in each grid cell. This will be useful when fitting the model in stan.
# - A ppp object which is a spatstat object. This will be helpful when fitting the model with spatstat
# - The covariate, which is a grid of values

genDat_pp <- function(b1, b2, dim, max_lambda = lambda, plotdat = TRUE){
  # Define the window of interest
  win <- owin(c(0,dim[1]), c(0,dim[2]))
  
  # set number of pixels to simulate an environmental covariate
  spatstat.options(npixel=c(dim[1],dim[2]))
  
  y0 <- seq(win$yrange[1], win$yrange[2],
            length=spatstat.options()$npixel[2])
  x0 <- seq(win$xrange[1], win$xrange[2],
            length=spatstat.options()$npixel[1])
  
  # Change the gridcov to a matrix of ones
  gridcov <- matrix(1, nrow = length(y0), ncol = length(x0))
  
  # Set the coefficients
  beta0 <- b1
  beta1 <- b2
  
  # Define the intensity function based on gridcov and coefficients
  intensity <- exp(beta0 + beta1 * gridcov)
  
  # Scale the intensity to ensure values are between 0 and 6
  scaled_intensity <- intensity * (lambda / max(intensity))
  
  # Simulate the point pattern using the scaled intensity
  pp <- rpoispp(im(scaled_intensity, xcol = x0, yrow = y0))
  
  # We count the number of points in each grid cell, plot it and make a vector out of it
  ## Divides window into quadrats and counts the numbers of points in each quadrat
  qcounts <- quadratcount(pp, ny = dim[1], nx = dim[2])
  ## converts it into density for plot later
  dens <- density(pp) 
  ## converts it into a vector and saved as Lambda
  Lambda <- as.vector(t(qcounts)) # We have to use t() as we need to construct the vector with the column first
  
  if (plotdat == TRUE) {
    par(mfrow=c(1,2), mar=c(2,2,1,1), mgp=c(1,0.5,0))
    plot(im(gridcov), main = 'Covariate')
    plot(dens, main = 'Intensity')
  }
  
  # Return a list with which I can play with
  return(list(Lambda = Lambda, pp = pp, gridcov = gridcov))
}

### TESTING
set.seed(123)
b1 <- 2
b2 <- 3
dim <- c(20,20)
lambda <- 6

pp <- genDat_pp(b1, b2, dim, lambda) 

pp$Lambda

### breakdown of the code genDat_pp to set lambda = 6
# # Define the window of interest
# win <- owin(c(0,dim[1]), c(0,dim[2]))
# 
# # set number of pixels to simulate an environmental covariate
# spatstat.options(npixel=c(dim[1],dim[2]))
# 
# y0 <- seq(win$yrange[1], win$yrange[2],
#         length=spatstat.options()$npixel[2])
# x0 <- seq(win$xrange[1], win$xrange[2],
#         length=spatstat.options()$npixel[1])
# 
# # Change the gridcov to a matrix of ones
# gridcov <- matrix(1, nrow = length(y0), ncol = length(x0))
# 
# # Set the coefficients
# beta0 <- b1
# beta1 <- b2
# 
# # Define the intensity function based on gridcov and coefficients
# intensity <- exp(beta0 + beta1 * gridcov)
# 
# # Scale the intensity to ensure values are between 0 and 6 by cancelling out the intensity generated?
# scaled_intensity <- intensity * (lambda / max(intensity))


# 
# # Simulate the point pattern using the scaled intensity
# pp <- rpoispp(im(scaled_intensity, xcol = x0, yrow = y0))
# 
# # We count the number of points in each grid cell, plot it and make a vector out of it
# ## Divides window into quadrats and counts the numbers of points in each quadrat
# qcounts <- quadratcount(pp, ny = dim[1], nx = dim[2])
# ## converts it into density for plot later
# dens <- density(pp) 
# ## converts it into a vector and saved as Lambda
# Lambda <- as.vector(t(qcounts)) # We have to use t() as we need to construct the vector with the column first
# 
# if (plotdat == TRUE) {
# par(mfrow=c(1,2), mar=c(2,2,1,1), mgp=c(1,0.5,0))
# plot(im(gridcov), main = 'Covariate')
# plot(dens, main = 'Intensity')
# }
# 
# # Return a list with which I can play with
# list(Lambda = Lambda, pp = pp, gridcov = gridcov)

### Each grid and their respective call times
# Define lambda values from the point process
lambda_values <- pp$Lambda

# Initialize a list to store call times for each grid
all_call_times <- list()

# Generate and print call times for each grid using lambda values
for (i in seq_along(lambda_values)) {
  cat("Grid", i, "Lambda:", lambda_values[i], "\n")
  call_times <- generate_owl_call_times(lambda_values[i])
  all_call_times[[i]] <- call_times
  cat("Call Times for Grid", i, ":", call_times, "\n\n")
}

# Convert times to "HH:MM" format for each grid
times_formatted <- lapply(all_call_times, function(call_times) {
  sapply(call_times, convert_decimal_to_time)
})

# Print the formatted times for each grid
for (i in seq_along(times_formatted)) {
  cat("Call Times for Grid", i, ":", times_formatted[[i]], "\n")
}


