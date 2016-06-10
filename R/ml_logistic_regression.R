spark_ml_logistic_regression <- function(x, response, features, intercept = TRUE,
                                         alpha = 0, lambda = 0)
{
  # ensure 'response' vector is encoded as numeric
  tbl <- eval(substitute(
    mutate(x, response = as.double(response)),
    list(response = as.name(response))
  ))

  scon <- spark_scon(x)
  df <- as_spark_dataframe(tbl)

  lr <- spark_invoke_static_ctor(
    scon,
    "org.apache.spark.ml.classification.LogisticRegression"
  )

  tdf <- spark_assemble_vector(scon, df, features, "features")

  model <- lr %>%
    spark_invoke("setMaxIter", 10L) %>%
    spark_invoke("setLabelCol", "response") %>%
    spark_invoke("setFeaturesCol", "features") %>%
    spark_invoke("setFitIntercept", as.logical(intercept)) %>%
    spark_invoke("setElasticNetParam", as.double(alpha)) %>%
    spark_invoke("setRegParam", as.double(lambda)) %>%
    spark_invoke("fit", tdf)

  model
}

as_logistic_regression_result <- function(model, features, response) {

  coefficients <- model %>%
    spark_invoke("coefficients") %>%
    spark_invoke("toArray")
  names(coefficients) <- features

  has_intercept <- spark_invoke(model, "getFitIntercept")
  if (has_intercept) {
    intercept <- spark_invoke(model, "intercept")
    coefficients <- c(coefficients, intercept)
    names(coefficients) <- c(features, "(Intercept)")
  }

  summary <- spark_invoke(model, "summary")
  areaUnderROC <- spark_invoke(summary, "areaUnderROC")
  roc <- spark_dataframe_collect(spark_invoke(summary, "roc"))

  ml_model("logistic_regression", model,
           response = response,
           features = features,
           coefficients = coefficients,
           roc = roc,
           area.under.roc = areaUnderROC
  )
}

#' Logistic regression from a dplyr source
#'
#' Fit a logistic model using \code{spark.lm}.
#'
#' See \url{https://spark.apache.org/docs/latest/ml-classification-regression.html}
#' for more information on how regression is implemented in Spark.
#'
#' @param x A dplyr source.
#' @param response The prediction column
#' @param features List of columns to use as features
#' @param intercept TRUE to fit the intercept
#' @param alpha The \emph{elastic net} mixing parameter.
#' @param lambda The \emph{regularization penalty}.
#'
#' @export
ml_logistic_regression <- function(x, response, features, intercept = TRUE,
                                   alpha = 0, lambda = 0) {
  fit <- spark_ml_logistic_regression(x, response, features, intercept,
                                      alpha, lambda)
  as_logistic_regression_result(fit, features, response)
}

#' @export
print.ml_model_logistic_regression <- function(x, ...) {

  # report what model was fitted
  formula <- paste(x$response, "~", paste(x$features, collapse = " + "))
  cat("Call: ", formula, "\n\n", sep = "")

  # report coefficients
  cat("Coefficients:", sep = "\n")
  print(x$coefficients)
}

#' @export
residuals.ml_model_logistic_regression <- function(x, ...) {
  stop("residuals not yet available for Spark logistic regression")
}

#' @export
fitted.ml_model_logistic_regression <- function(x, ...) {
  x$.model %>%
    spark_invoke("summary") %>%
    spark_invoke("predictions") %>%
    spark_dataframe_read_column("prediction")
}

#' @export
predict.ml_model_logistic_regression <- function(object, newdata, ...) {
  sdf <- as_spark_dataframe(newdata)
  assembled <- spark_assemble_vector(sdf$scon, sdf, features(object), "features")
  predicted <- spark_invoke(object$.model, "transform", assembled)
  spark_dataframe_read_column(predicted, "prediction")
}