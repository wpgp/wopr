#' Generate token from username/password to access password-protected population layer from ESRI ImageService
#' @param u chr Username
#' @param p chr Password
#' @return chr Generated token
#' @export


getToken_ESRI <- function(u, p) {
  
  url <- "https://gis.worldpop.org/portal/sharing/rest/generateToken"
  
  args <- list(username = u,
               password = p,
               f = 'json',
               expiration = 86400,
               client ='referer',
               referer='localhost')
  
  resp <- httr::POST(url, body=args)
  
  if (httr::http_type(resp) != "application/json") {
    stop("ArcGIS API did not return json", call. = FALSE)
  }
  
  parsed <- suppressMessages(httr::content(resp,
                                           encoding = "UTF-8",as='parsed'))
  ),simplifyVector = FALSE)
  
  
  if (httr::status_code(resp)!=200) {
    mssg <- sprintf("Error ", parsed$error$message)
    stop(mssg, call. = FALSE)
  }
  
  if(is.null(parsed$token)){
    output <- parsed$error$code # if 400 issue in u/pwd
    
  } else {
    output <- parsed$token
  }
  
  return(output)
  
}