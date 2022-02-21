# box::use(
#   targets[
#     #plot = tar_visnetwork,
#     tgt = tar_target,
#     ...
#   ],
#   ML[...]
# )

library(targets)
library(ML)
library(future)
#library(future.callr)
#plan(multisession)

tgt <- tar_target

data(concrete, package = "modeldata")
#tar_option_set(packages = c("rlang", "tidyverse", "tidymodels"))

tar_option_set(packages = c(
  #' @note tidymodels interface
  "rsample", "recipes", "parsnip", "tune", "finetune", "yardstick",
  "workflows", "workflowsets",
  
  #' @note data wrangling: tidyverse
  "dplyr", "ggplot2", "rlang", "forcats",
  
  #' @note neural network
  "keras", "glmnet", "earth", "kernlab",
  "kknn", "rpart",
  
  #' @note tree models
  "ranger", "xgboost", "baguette", "rules"
))

tidymodels::tidymodels_prefer()

list(
  ### TODO: data input step
  ### TODO: validate data step
  ### TODO: data preparation step
  tgt(clean, {
    concrete |>
      group_by(across(-compressive_strength)) |>
      summarise(compressive_strength = mean(compressive_strength),
                .groups = "drop")
  }),
  tgt(init, {
    set.seed(1)
    initial_split(clean, strata = compressive_strength)
  }),
  tgt(train, training(init)),
  tgt(test, testing(init)),
  tgt(folds, vfold_cv(train, strata = compressive_strength, repeats = 1)),
  tgt(recipes, 
      list(
        normalized_recipe =
          recipe(compressive_strength ~ ., data = train) |>
          step_normalize(all_predictors()),
        poly_recipe = 
          recipe(compressive_strength ~ ., data = train) |>
          step_normalize(all_predictors()) |>
          step_poly(all_predictors()) |> 
          step_interact(~ all_predictors():all_predictors()),
        keras_recipe = 
          recipe(compressive_strength ~ ., data = train) |> 
          step_center(all_predictors(), -all_outcomes()) |>
          step_scale(all_predictors(), -all_outcomes()) |>
          prep()
      )
  ),
  ### TODO: model specification: make this environment variable
  tgt(models, {
    list(
      linear_reg_spec =
        linear_reg(penalty = tune(), mixture = tune()) |>
        set_engine("glmnet"),
      
      mars_spec =
        mars(prod_degree = tune()) |>  #<- use GCV to choose terms
        set_engine("earth") |>
        set_mode("regression"),
      
      svm_r_spec =
        svm_rbf(cost = tune(), rbf_sigma = tune()) |>
        set_engine("kernlab") |>
        set_mode("regression"),
      
      svm_p_spec =
        svm_poly(cost = tune(), degree = tune()) |>
        set_engine("kernlab") |>
        set_mode("regression"),
      
      knn_spec =
        nearest_neighbor(neighbors = tune(), dist_power = tune(), weight_func = tune()) |>
        set_engine("kknn") |>
        set_mode("regression"),
      
      cart_spec =
        decision_tree(cost_complexity = tune(), min_n = tune()) |>
        set_engine("rpart") |>
        set_mode("regression"),
      
      bag_cart_spec =
        bag_tree() |>
        set_engine("rpart", times = 50L) |>
        set_mode("regression"),
      
      rf_spec =
        rand_forest(mtry = tune(), min_n = tune(), trees = 1000) |>
        set_engine("ranger") |>
        set_mode("regression"),
      
      xgb_spec =
        boost_tree(tree_depth = tune(), learn_rate = tune(), loss_reduction = tune(),
                   min_n = tune(), sample_size = tune(), trees = tune()) |>
        set_engine("xgboost") |>
        set_mode("regression"),
      
      cubist_spec =
        cubist_rules(committees = tune(), neighbors = tune()) |>
        set_engine("Cubist")
    )
  }
  ),
  tgt(flows, {
    list(
      #normalized = workflow_set(
       # list(
        #  normalized = recipes$normalized_recipe),
        #list(#SVM_radial = models$svm_r_spec,
             #SVM_poly = models$svm_p_spec,
             #KNN = models$knn_spec)
    #  ),
      no_pre_proc = workflow_set(
        list(
          simple = workflow_variables(compressive_strength,
                                      everything())
          ),
        list(MARS = models$mars_spec)#,
             #CART = models$cart_spec,
             ### FIXME: CART_bagged is currently bugged
             #CART_bagged = models$bag_cart_spec,
             #RF = models$rf_spec)#,
             #boosting = models$xgb_spec,
             #Cubist = models$cubist_spec)
      )#,
      #with_features = workflow_set(
       # list(full_quad = recipes$poly_recipe),
        #list(
         # linear_reg = models$linear_reg_spec,
          #KNN = models$knn_spec)
      #)
    ) |>
      bind_rows() |>
      mutate(wflow_id = gsub("(simple_)|(normalized_)", "", wflow_id))
  }
  ),
  tgt(control, {
    list(
      grid = 
    control_grid( # 25200 models
      save_pred = TRUE,
      parallel_over = "everything",
      save_workflow = TRUE
    ),
    race = control_race( # 4.488 models
      save_pred = TRUE,
      parallel_over = "everything",
      save_workflow = TRUE
    )
    )
  }, packages = c("finetune")),
  tgt(results, {
    flows |>
      workflow_map(
        "tune_race_anova",
        seed = 1503,
        resamples = folds,
        grid = 25,
        control = control$race,
        verbose = TRUE
      )
  }#, packages = c("workflowsets", "finetune")
  ),
  #tgt(ranking, {
  #  results |>
   #   filter(.metric == "rmse") |>
    #  select(model, .config, rmse = mean, rank)
  #}, packages = c("dplyr"))
  ### TODO: results plotting
  tgt(ranking, {
    autoplot(
      results,
      rank_metric = "rmse",  
      metric = "rmse",       
      select_best = TRUE    
    ) +
      geom_text(aes(y = mean - 1/2, label = wflow_id), angle = 90, hjust = 1) +
      lims(y = c(3.0, 9.5)) +
      theme(legend.position = "none")
  }),
  tgt(winners_pre_test, {
    results |>
      extract_workflow_set_result("MARS") |>
      select_best(metric = "rmse")
  }),
  tgt(winners_post_test, {
    results |>
      extract_workflow("MARS") |>
      finalize_workflow(winners_pre_test) |>
      last_fit(split = init)
  }),
  tgt(metrics, {
    collect_metrics(winners_post_test)
  }),
  tgt(predictions, {
    collect_predictions(winners_post_test)
  }),
  tgt(visual_verify, {
    ggplot(predictions, aes(compressive_strength, .pred)) + 
      geom_abline(color = "gray50", lty = 2) + 
      geom_point(alpha = .5) +
      labs(x = "observed", y = "predicted")
  }
  ),
  
  
  
  
  
  tar_target(
    keras_rec,
    prepare_recipe(train),
    format = "qs",
    deployment = "main"
  ),
  tar_target(
    units,
    c(16, 32),
    deployment = "main"
  ),
  tar_target(
    act,
    c("relu", "sigmoid"),
    deployment = "main"
  ),
  tar_target(
    run,
    test_model(init, keras_rec, units1 = units, act1 = act),
    pattern = cross(units, act),
    format = "fst_tbl"
  ),
  tar_target(
    best_run,
    run %>%
      top_n(1, accuracy) %>%
      head(1),
    format = "fst_tbl",
    deployment = "main"
  ),
  tar_target(
    best_model,
    train_best_model(best_run, keras_rec),
    format = "keras"
  )
  
  
  
  
  
  
  ### TODO: data pre-processing step [recipe specification]
  ### TODO: workflowsets step for dependent models [workflowsets]
  ### TODO: hyperparameter tuning step {{ control grid // finetune ?}}
  ### TODO: Results visualization step [ggplot2]
  ### TODO: Results ranking step, best model from tuning results
  ### TODO: finalize workflow step, fitting data to test set
  ### TODO: collect model performance metrics
  ### TODO: test predictions on validation set
  ### TODO: save best models to package data as environment
  # https://github.com/ropensci/targets/discussions/588
)
