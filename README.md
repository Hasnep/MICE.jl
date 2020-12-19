# MICE.jl

The start of an implementation of the MICE algorithm in Julia.

## Development

The plan for this package is to compare its output to the output other iterative imputation packages, including the R package [`mice`](https://cran.r-project.org/web/packages/mice/index.html) and [scikitlearn's `IterativeImputer`](https://scikit-learn.org/stable/modules/generated/sklearn.impute.IterativeImputer.html).

To generate reproducible comparison datasets, the `mice` package is run in a docker container.

```bash
cd test/comparison/
# Build the container
docker build -t mice_jl_r_script .
# Run the container
docker run --rm -v "$(pwd)/data/:/data/" mice_jl_r_script
```
