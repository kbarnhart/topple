Code, inputs, and outputs for Barnhart et al. (2014)

Barnhart, K. R., R. S. Anderson, I. Overeem, C. Wobus, G. D. Clow, and F. E. Urban (2014), Modeling erosion of ice-rich permafrost bluffs along the Alaskan Beaufort Sea coast, J. Geophys. Res. Earth Surf., 119, [doi:10.1002/2013JF002845](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2013JF002845).

This code was developed between 2010 and 2014 for the above paper.

The model was run using the with the drivers `topple0501driver_*.m` which in turn run the functions `topple0501fxn_*.m`.

* `topple0501driver.m` runs the long-term model runs.
* `topple0501driver_observationPeriod.m` runs the model runs for the 2010 observation period.
* `topple0501driver_observationPeriodMOVIE.m` creates the example movie.

This produces output .mat files in directories, one file for each simulation.

In Dec 2019, the code was "tested" with R2019b. Tested in that the scripts were
run and completed. The original output .mat files were tracked in git and are provided here. When I re-ran the scripts, they change the .mat files slightly. I don't have the time to track down exactly how and why they are different. The difference may be minimal, I don't know. Note that this project occurred before I learned most of what I know about software development, continuous integration, and testing.

How long does this model take to run? Depends on how many timesteps you need it to run for... In this project I used timesteps of 1 hour (so the long term simulations had 289272 timesteps and the short term simulations had 2664). A quick test in 2019 indicates that long term simulations take about 10 minutes and short term ones less than a second (on a 2015 MacBook Pro, single core run). Note that no serious attempt to profile, optimize, or parallelize this code has occurred.

If you have any interest in the following, please let me know via GitHub issue. I'd be happy to provide a (likely minimal) amount of support for the following:

* Converting the code to python
* Making it a more functional library (in python)
* Making it more generalizable.

Cheers,
Katy
