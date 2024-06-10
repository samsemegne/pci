## code to prepare `pci_info` dataset goes here


new_bounds = function(
    target, lower, is_lower_inclusive, upper, is_upper_inclusive)
{
  stopifnot(exprs = {
    vek::is_chr_vec_nxb1(target)
    vek::is_num_vec_nxy1(lower)
    vek::is_lgl_vec_nx1(is_lower_inclusive)
    vek::is_num_vec_nxy1(upper)
    vek::is_lgl_vec_nx1(is_upper_inclusive)
    lower < upper
  })

  return(list(
    type = "bounds",
    target = target,
    lower = lower,
    is_lower_inclusive = is_lower_inclusive,
    upper = upper,
    is_upper_inclusive = is_upper_inclusive
  ))
}


new_df = function(...) {
  return(data.frame(
    ...,
    row.names = NULL,
    check.rows = FALSE,
    check.names = TRUE,
    fix.empty.names = TRUE,
    stringsAsFactors = FALSE
  ))
}


################################################################################
##                         Process capability indices                         ##
################################################################################

info__C_p = new_df(
  pci_id = "C_p",
  name_r = "C_p",
  name_latex = "C_p",
  name_r_expr = "C[p]",
  expr_r = "(usl - lsl) / (dl * sigma)",
  eq_latex = "C_p = \\frac{\\text{USL} - \\text{LSL}}{L \\sigma}",
  attributes = I(list(
    new_bounds("C_p", 0L, FALSE, Inf, FALSE)
  ))
)


# ------------------------------------------------------------------------------
info__C_pl = new_df(
  pci_id = "C_pl",
  name_r = "C_pl",
  name_latex = "C_{pl}",
  name_r_expr = "C[pl]",
  expr_r = "(mu - lsl) / (l * sigma)",
  eq_latex = "C_{pl} = \\frac{\\mu - \\text{LSL}}{L \\sigma}",
  attributes = I(list(
    new_bounds("C_pl", -Inf, FALSE, Inf, FALSE)
  ))
)


# ------------------------------------------------------------------------------
info__C_pu = new_df(
  pci_id = "C_pu",
  name_r = "C_pu",
  name_latex = "C_{pu}",
  name_r_expr = "C[pu]",
  expr_r = "(usl - mu) / (l * sigma)",
  eq_latex = "C_{pu} = \\frac{\\text{USL} - \\mu}{L \\sigma}",
  attributes = I(list(
    new_bounds("C_pu", -Inf, FALSE, Inf, FALSE)
  ))
)


# ------------------------------------------------------------------------------
info__C_pk = new_df(
  pci_id = "C_pk",
  name_r = "C_pk",
  name_latex = "C_{pk}",
  name_r_expr = "C[pk]",
  expr_r = paste("(usl - lsl) / (dl * sigma) * ",
    "(1 - (abs(((usl + lsl) / 2) - mu)) / ",
    "((usl - lsl) / 2))",
    collapse = ""
  ),
  eq_latex = "C_{pk} = \\min(C_{pl}, C_{pu})",
  attributes = I(list(
    new_bounds("C_pk", -Inf, FALSE, Inf, FALSE)
  ))
)


# ------------------------------------------------------------------------------
info__C_pm = new_df(
  pci_id = "C_pm",
  name_r = "C_pm",
  name_latex = "C_{pm}",
  name_r_expr = "C[pm]",
  expr_r = paste(
    "(usl - lsl) / ",
    "(dl * sqrt(sigma^2 + (mu - target)^2))",
    collapse = ""
  ),
  eq_latex = paste(
    "C_{pm} = \\frac{\\text{USL} - \\text{LSL}}{L \\sqrt{\\sigma^2 + ",
    "(\\mu - T)^2}}",
    collapse = ""
  ),
  attributes = I(list(
    new_bounds("C_pm", 0L, FALSE, Inf, FALSE)
  ))
)


################################################################################
##                         Construct the data frame                           ##
################################################################################

pci_info = rbind.data.frame(
  info__C_p,
  info__C_pl,
  info__C_pu,
  info__C_pk,
  info__C_pm,

  deparse.level = 1L,
  make.row.names = TRUE,
  stringsAsFactors = FALSE,
  factor.exclude = TRUE
)

row.names(pci_info) = pci_info$pci_id

usethis::use_data(pci_info, internal = FALSE, overwrite = TRUE,
                  compress = "bzip2", version = 2, ascii = FALSE)

