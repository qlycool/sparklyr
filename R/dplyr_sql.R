# Helper functions to support dplyr sql operations

spark_sql_count_rows <- function(op, con) {
  countQuery <- select_spark_query(
    from = sql_build(op$x, con = con),
    select = sql("count(*) as rowcount")
  )

  countSql <- sql_render(countQuery, con = con)
  countResult <- dbGetQuery(con, countSql)

  countResult[[1]]
}

#' @export
sql_build.op_sample_n <- function(op, con, ...) {
  countTotal <- spark_sql_count_rows(op, con)

  query <- select_spark_query(
    from = sql_build(op$x, con = con),
    select = sql("*, row_number() OVER () as rownumber")
  )

  sampleRate <- floor(countTotal / op$args$size)

  query <- select_spark_query(
    from = query,
    select = sql("*"),
    where = sql(paste("rownumber %", sampleRate, "=", 0))
  )

  query
}

#' @export
sql_build.op_sample_frac <- function(op, con, ...) {
  countTotal <- spark_sql_count_rows(op, con)

  query <- select_spark_query(
    from = sql_build(op$x, con = con),
    select = sql("*, row_number() OVER () as rownumber")
  )

  sampleRate <- floor(countTotal / (countTotal * op$args$size))

  query <- select_spark_query(
    from = query,
    select = sql("*"),
    where = sql(paste("rownumber %", sampleRate, "=", 0))
  )

  query
}
