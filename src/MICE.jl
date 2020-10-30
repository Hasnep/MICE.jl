module MICE

import Tables
using DataFrames
using GLM
using Statistics: mean
using StatsModels

function mice(data)
    @assert Tables.istable(data) "data should be a table for now please and thanks."

    response_variable = rand(names(data))
    explanatory_variables = filter(n -> n != response_variable, names(data))

    
    data_imputed = copy(data)
    for n in explanatory_variables
        imputed_value = data_imputed[n] |> skipmissing |> mean
        data_imputed[n] =  coalesce.(data_imputed[n], imputed_value)
        println(n)
    end
    
    # Only fit the model to rows where the response variable is not missing
    data_train = dropmissing(data_imputed, response_variable)
    # Fit a linear model with an intercept and each explanatory variable
    f = term(response_variable) ~ term(1) + foldl(+, term.(explanatory_variables))
    model = lm(f, data_train)

    # Predict 
    predicted_values = predict(model, data_imputed)
    # Replace missing values with the new imputed values
    data_imputed[response_variable] = coalesce.(data_imputed[response_variable], predicted_values)

    return data
end

end
