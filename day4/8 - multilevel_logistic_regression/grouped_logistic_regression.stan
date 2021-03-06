data{
  int<lower=1> N;
  int<lower=1> N_location;
  int<lower=1, upper=N_location> location[N];

  int<lower=1> N_method;
  int<lower=1, upper=N_method> method[N];

  vector[N] x;
  int y[N];
}

parameters{
  vector[N_location] alpha_location;
  vector[N_location] beta_location;
}

model{
  beta_location ~ normal(0,5);
  alpha_location ~ normal(0,5);

  y ~ bernoulli_logit(beta_location[location] .* x + alpha_location[location]);
}

generated quantities{
  real p_hat_ppc = 0;
  vector[N_location] p_hat_location_ppc = rep_vector(0, N_location);
  vector[N_method] p_hat_method_ppc = rep_vector(0, N_method);

  {
    vector[N_location] location_counts = rep_vector(0, N_location);
    vector[N_method] method_counts = rep_vector(0, N_method);
    
    vector[N] alpha_indiv = alpha_location[location];
    vector[N] beta_indiv =  beta_location[location];
    
    for(n in 1:N){
      real logit_theta = beta_indiv[n] + x[n] + alpha_indiv[n];
      if (bernoulli_logit_rng(logit_theta)){
        p_hat_ppc = p_hat_ppc + 1;
        p_hat_location_ppc[location[n]] =  p_hat_location_ppc[location[n]] + 1;
        p_hat_method_ppc[method[n]] =  p_hat_method_ppc[method[n]] + 1;
        
      }
      location_counts[location[n]]=location_counts[location[n]]+1;
      method_counts[method[n]]=method_counts[method[n]]+1;
    
    }
    p_hat_ppc =p_hat_ppc/N;
    p_hat_location_ppc =p_hat_location_ppc ./ location_counts;
    p_hat_method_ppc =p_hat_method_ppc ./ method_counts;
    
  }
}
