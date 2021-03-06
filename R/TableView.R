#'@importFrom jsonlite toJSON
TableView <- function(ctx, df, var_name){
  if (missing(var_name)){
    var_name <- ctx$get(JS("_.uniqueId('tv')"))
  }

  set_data <- function(df, convert=TRUE){
    if (convert){
      nms <- jsonlite::toJSON(names(df))
      df <- jsonlite::toJSON(df, dataframe = "values")
      ctx$assign(var_name, JS(df))
      ctx$assign(var_name, JS(paste0("to_table_view(",var_name,",",nms,")")))
    } else {
      df <- jsonlite::toJSON(df, dataframe = "values")
      ctx$assign(var_name, JS(df))
      ctx$assign(var_name, JS(paste0("to_table_view(",var_name,", false)")))
    }
  }

  get_data <- function(){
    ctx$get(JS(paste0("to_objects(",var_name,".data)")))
  }

  get_matrix <- function(){
    ctx$get(JS(paste0(var_name, ".data")))
  }

  raw <- function(){
    ctx$get(var_name)
  }

  to_csv <- function(){
    csv <- ctx$call("to_csv", JS(var_name))
    gsub("\r", "", csv) # remove those \r's
    #csv
  }

  from_csv <- function(txt){
    ctx$assign(var_name, txt)
    ctx$assign(var_name, JS(paste0("from_csv(",var_name,")")))
  }

  if (!missing(df)){
    set_data(df)
  }
  else{
    set_data(data.frame(x=NA))
  }

  structure( list( set_data=set_data
                 , get_data=get_data
                 , var_name=var_name
                 , raw=raw
                 , to_csv=to_csv
                 , from_csv=from_csv
                 , get_matrix=get_matrix
                 , ctx=ctx
                 )
             , class="TableView"
  )
}

#' @export
print.TableView <- function(x, n=6, ...)
{
  cat("  First", n, "and last", n, "patch lines:\n")
  patch_data <- x$get_data()
  p <- rbind(head(patch_data, n=n),
             "..."=rep("...", length=ncol(patch_data)),
             tail(patch_data, n=n)
  )
  print(p, ...)
  cat("\n")
  invisible(x)
}

#' @export
print.data_diff <- function(x, ...)
{
  df.s <- attr(x, "summary")
  cat("Daff Comparison:", sQuote(df.s$source_name), "vs.", sQuote(df.s$target_name), "\n")
  NextMethod()
}
