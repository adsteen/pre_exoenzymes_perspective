multi_G_model <- function(t, x, params) {
  # Extract the state variables
  labile <- x["labile"]
  recalcitrant <- x["recalcitrant"]
  #G_T <- x["G_T"] # not sure whether this is necessary
  
  # now extract the parameters
  k_l <- params["k_l"]
  k_r <- params["k_r"]
  k_l_r <- params["k_l_r"]
  
  # now code the model equations
  
  #dG_T_dt <- -k_l * G_l - k_r * G_r
  dG_l_dt <- k_l * labile - k_l_r * labile
  dG_r_dt <- k_r * recalcitrant + k_l_r * labile
  
  #dxdt <- c(dG_T_dt, dG_l_dt, dG_r_dt)
  dxdt <- c(dG_l_dt, dG_r_dt)

  list(dxdt)
}

pivot_ODE <- function(df, names_to="parameter", values_to="G") {
  df %>%
    pivot_longer(-time, names_to = names_to, values_to = values_to)
}

plot_ODE_data <- function(df, print=FALSE, theme=NULL) {
  #browser()
  p <- ggplot(df, aes(x=time, y=G, color=case))+ 
    geom_line() + 
    scale_color_brewer(palette = "Dark2") + 
    facet_wrap(~parameter, nrow = 1) 
  
  # allows to pass themes as parameter or not
  if(!is.null(theme)) {
    p <- p + theme
  }
  
  if(print) {
    print(p)
  }
  
  p
}

sim_G <- function(params.enz, params.no.enz, 
                  x.start = c(G_l = 0.75, G_r = 0.25), 
                  times = seq(0, 100, 0.1),
                  print.plot=TRUE) {
  
  # Create the "base" model with extracellular enzymes
  enz <- deSolve::ode(
    func=multi_G_model,
    y=xstart,
    times=times,
    parms=params.enz) %>%
    as.data.frame()  %>%
    pivot_ODE()
  
  # Create the 'no-enzyme' case
  no_enz <- deSolve::ode(
    func=multi_G_model,
    y=xstart,
    times=times,
    parms=params.no.enz) %>%
    as.data.frame() %>%
    pivot_ODE()
  
  
  d_full <- list("enzymes"=enz, "no enzymes"=no_enz) %>%
    bind_rows(.id = "case")
  
  if(print.plot==TRUE) {
    p <- plot_ODE_data(d_full)
    print(p)
  }
  d_full
}
