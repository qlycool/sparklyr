% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_interface.R
\name{spark_read_csv}
\alias{spark_read_csv}
\title{Read a CSV file into a Spark DataFrame}
\usage{
spark_read_csv(sc, name, path, header = TRUE, delimiter = ",",
  quote = "\\"", escape = "\\\\", charset = "UTF-8", null_value = NULL,
  options = list(), repartition = 0, memory = TRUE, overwrite = TRUE)
}
\arguments{
\item{sc}{The Spark connection}

\item{name}{Name of table}

\item{path}{The path to the file. Needs to be accessible from the cluster. Supports: "hdfs://" or "s3n://"}

\item{header}{Should the first row of data be used as a header? Defaults to \code{TRUE}.}

\item{delimiter}{The character used to delimit each column, defaults to \code{,}.}

\item{quote}{The character used as a quote, defaults to \code{"hdfs://"}.}

\item{escape}{The chatacter used to escape other characters, defaults to \code{\\}.}

\item{charset}{The character set, defaults to \code{"UTF-8"}.}

\item{null_value}{The character to use for default values, defaults to \code{NULL}.}

\item{options}{A list of strings with additional options.}

\item{repartition}{Total of partitions used to distribute table or 0 (default) to avoid partitioning}

\item{memory}{Load data eagerly into memory}

\item{overwrite}{Overwrite the table with the given name if it already exists}
}
\value{
Reference to a Spark DataFrame / dplyr tbl
}
\description{
Read a CSV file into a Spark DataFrame
}
\details{
You can read data from HDFS (\code{hdfs://}), S3 (\code{s3n://}), as well as 
  the local file system (\code{file://}). 
  
If you are reading from a secure S3 bucket be sure that the \code{AWS_ACCESS_KEY_ID} and 
  \code{AWS_SECRET_ACCESS_KEY} environment variables are both defined.
}
\seealso{
Other reading and writing data: \code{\link{spark_read_json}},
  \code{\link{spark_read_parquet}},
  \code{\link{spark_write_csv}},
  \code{\link{spark_write_json}},
  \code{\link{spark_write_parquet}}
}

