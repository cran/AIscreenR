% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sample_references.R
\name{sample_references}
\alias{sample_references}
\title{Random sample references}
\usage{
sample_references(
  data,
  n,
  with_replacement = FALSE,
  prob_vec = rep(1/n, nrow(data))
)
}
\arguments{
\item{data}{Dataset containing the titles and abstracts wanted to be screened.}

\item{n}{A non-negative integer giving the number of rows to choose.}

\item{with_replacement}{Logical indicating if sampling should be done with of without replacement.
Default is \code{FALSE}.}

\item{prob_vec}{'A vector of probability weights for obtaining the elements of the vector being sampled.'
Default is a vector of 1/n.}
}
\value{
A dataset with n rows.
}
\description{
\code{sample_references}samples n rows from the dataset with titles and abstracts either with or without replacement.
This function is supposed to support the construct of a test dataset,
as suggested by \href{https://osf.io/preprints/osf/yrhzm}{Vembye et al. (2024)}.
}
\examples{

excl_test_dat <- filges2015_dat[1:200,] |> sample_references(100)

}
\references{
Vembye, M. H., Christensen, J., Mølgaard, A. B., & Schytt, F. L. W. (2024)
\emph{GPT API Models Can Function as Highly Reliable Second Screeners of Titles and Abstracts in Systematic Reviews:
A Proof of Concept and Common Guidelines} \url{https://osf.io/preprints/osf/yrhzm}
}
