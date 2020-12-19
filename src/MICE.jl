module MICE

using DataFrames
using GLM: fit, LinearModel, predict
using Statistics: mean
using StatsModels: term, schema, modelcols, apply_schema
import CSV
using StatsBase: sample

export mice

function mice(data::DataFrame; max_iterations = 5)
    data_missings = ismissing.(data)

    # Do naive imputation using means
    data_imputed = naive_imputation(data, mean)

    # Do better imputation using LMs
    for iteration in 1:max_iterations

        # TODO: Add early stopping when abs(max(X_t - X_{t-1}))/abs(max(X[known_vals])) < tol

        data_imputed_temp = copy(data_imputed)
        for response_variable in names(data)
            # The explanatory variables are all the other variables
            explanatory_variables = filter(n -> n != response_variable, names(data))

            # Fit a linear model with an intercept and each explanatory variable
            f = term(response_variable) ~ term(1) + foldl(+, term.(explanatory_variables))

            predicted_values = predictive_mean_matching(data_imputed, data_missings, f)

            # # Fit the model
            # # @info data_train
            # # @info f
            # # CSV.write("df.csv", data_train)
            # model = fit(LinearModel, f, data_train)
            # # Predict 
            # predicted_values::Vector = predict(model, data_imputed)

            # Replace missing values with the new imputed values
            data_imputed_temp[:, response_variable] = predicted_values
        end
        data_imputed = copy(data_imputed_temp)
    end
    return data_imputed
end

"""
Perform a naïve imputation of the missing values in `data` using the function `f`.
"""
function naive_imputation(data, f = mean)
    data_imputed = copy(data)
    for n in names(data)
        # Calculate the average of the non-missing values
        imputed_value = f(skipmissing(data_imputed[:, n]))
        # Replace the missing values with the imputed value
        data_imputed[:, n] = coalesce.(data_imputed[:, n], imputed_value)
    end
    return data_imputed
end

function predictive_mean_matching(data, data_missings, formula; n = 5)
    formula_data = apply_schema(formula, schema(formula, data))
    formula_missings = apply_schema(formula, schema(formula, data_missings))

    response_variable = modelcols(formula_data.lhs, data)
    response_missings = modelcols(formula_missings.lhs, data_missings)

    # Only fit the model to rows where the response variable is not missing
    data_train = data[.!response_missings, :]

    @info formula
    CSV.write("df.csv", data_train)
    model = fit(LinearModel, formula_data, data_train)
    predicted_values = predict(model, data)

    output = zeros(length(response_variable))
    for (i, is_missing) in enumerate(response_missings)
        if is_missing
            # Calculate the distance between the predicted value being imputed and the predicted values of the other points
            donor_candidates_distances = abs.(predicted_values[i] .- predicted_values)
            # Filter to only the candiates where the true value is known
            donor_candidates = filter((j, v) -> !response_missings[j], enumerate(donor_candidates_distances))
            donor_candidates = sort(donor_candidates, by = (j, v) -> v)[2:(n + 1)]
            # Choose one of the candidates to be the donor
            donor_index, _ = sample(donor_candidates)
            # Set the value being imputed to the donor value
            output[i] = response_column[donor_index]
        else
            output[i] = response_column[i]
        end
    end
    return output
end

end # module
