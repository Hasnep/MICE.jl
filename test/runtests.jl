using MICE
using Test
import CSV
using Glob
using FilePathsBase
using FilePathsBase: /
using DataFrames

Glob.glob(pattern, path::AbstractPath) = glob(pattern, string(path))

@testset "MICE.jl" begin
    input_file_paths = Path.(glob("*.csv", cwd() / "comparison" / "data" / "input"))
    @test length(input_file_paths) > 0 # Find input files
    input_datasets = Dict()
    for input_file_path in input_file_paths
        file_name = filename(input_file_path)
        input_datasets[file_name] = CSV.File(input_file_path, missingstring = "NA") |> DataFrame
    end

    output_datasets = Dict()
    for (dataset_name, datset) in input_datasets
        output_datasets[dataset_name] = mice(datset; max_iterations = 1)
    end
end
