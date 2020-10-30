module MICE

import Tables
using DataFrames
using GLM
using Statistics: mean
using StatsModels

function mice(data, max_iterations = 5)
    @assert Tables.istable(data) "data should be a table for now please and thanks."
    data_missings = ismissing.(data)

    # Do naive imputation using means
    data_imputed = copy(data)
    for n in names(data)
        # Calculate the mean of the non-missing values
        imputed_value = mean(skipmissing(data_imputed[n]))
        # Replace the missing values with the imputed value
        data_imputed[n] = coalesce.(data_imputed[n], imputed_value)
    end

    # Do better imputation using LMs
    for iteration = 1:max_iterations
        data_imputed_temp = copy(data_imputed)
        for response_variable in names(data)
            # Only fit the model to rows where the response variable is not missing
            response_missings = data_missings[response_variable]
            data_train = data_imputed[.!response_missings, :]
            
            # The explanatory variables are all the other variables
            explanatory_variables = filter(n -> n != response_variable, names(data))
            
            # Fit a linear model with an intercept and each explanatory variable
            f = term(response_variable) ~ term(1) + foldl(+, term.(explanatory_variables))
            
            # Fit the model
            model = lm(f, data_train)

            # Predict 
            predicted_values = predict(model, data_imputed)

            # Replace missing values with the new imputed values
            data_imputed_temp[response_missings, response_variable] .=    predicted_values[response_missings]
        end
        data_imputed = copy(data_imputed_temp)
    end

    return data_imputed
end

end # module
