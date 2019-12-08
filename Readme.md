Code, inputs, and outputs for Barnhart et al. (2014)

Barnhart, K. R., R. S. Anderson, I. Overeem, C. Wobus, G. D. Clow, and F. E. Urban (2014), Modeling erosion of ice-rich permafrost bluffs along the Alaskan Beaufort Sea coast, J. Geophys. Res. Earth Surf., 119, [doi:10.1002/2013JF002845](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2013JF002845).

This code was developed between 2010 and 2014 for the above paper.

The model was run using the with the drivers `topple0501driver_*.m` which in turn run the functions `topple0501fxn_*.m`.

* `topple0501driver.m` runs the long-term model runs.
* `topple0501driver_observationPeriod.m` runs the model runs for the 2010 observation period.
* `topple0501driver_observationPeriodMOVIE.m` creates the example movie. 

In Dec 2019, the code was "tested" with R2019b. Tested in that the scripts were
run and completed.
