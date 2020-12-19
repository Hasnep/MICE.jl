# MICE.jl

The start of an implementation of the MICE algorithm in Julia.

## Development

The plan for this package is to compare its output to other iterative imputation packages, including the R package [`mice`](https://cran.r-project.org/web/packages/mice/index.html) and [scikitlearn's `IterativeImputer`](https://scikit-learn.org/stable/modules/generated/sklearn.impute.IterativeImputer.html).

To generate reproducible comparison datasets, the `mice` package is run in a docker container.

```bash
cd test/comparison/
# Build the container
docker build -t mice_jl_r_script .
# Run the container
docker run --rm -v "$(pwd)/data/:/data/" mice_jl_r_script
```

## References

If you want to learn more about the MICE algorithm, these are the main sources I am using:

- Azur, M. _et al._ (2011). _Multiple imputation by chained equations: what is it and how does it work?_. [Link](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3074241/)
- van Buuren, S. (2018). _Flexible Imputation of Missing Data, Second Edition (2nd ed.)_. [Link](https://stefvanbuuren.name/fimd/)
