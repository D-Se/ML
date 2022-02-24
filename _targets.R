
# box::use(targets[#plot = tar_visnetwork, tgt = tar_target, ...], ML[...])
library(targets)
library(tarchetypes)
library(ML)
library(future)
#library(future.callr)
#plan(multisession)

tgt <- tar_target

### TODO: read actual data from external source in a tgt()
data(concrete, package = "modeldata")

### TODO: is this more efficient than hardcore for each target?
tar_option_set(error = "continue", packages = c(
  #' @note tidymodels interface
  #' TODO prune workflowsets --> individual targets for models.
  "rsample", "recipes", "parsnip", "tune", "finetune", "yardstick",
  "workflows", "workflowsets",
  
  #' @note data wrangling: tidyverse
  #' TODO forcats is only used by keras. Worth the dependency?
  "dplyr", "ggplot2", "rlang", "forcats", "purrr",
  # TODO replace readr and tidyr
  "readr", "tidyr",
  
  #' @note neural network
  "keras", "glmnet", "earth", "kernlab",
  "kknn", "rpart",
  
  #' @note tree models
  "ranger", "xgboost", "baguette", "rules",
  
  #' @note reporting
  "bookdown"
))

tidymodels::tidymodels_prefer()

list(
  ### TODO: data input step here
  ### TODO: validate data step
  #' @Donald use `pointblank`
  ### TODO: data preparation step
  tgt(clean, {
    concrete |>
      group_by(across(-compressive_strength)) |>
      summarise(compressive_strength = mean(compressive_strength),
                .groups = "drop")
  }),
  
  #####################
  #### Tidymodels #####
  #####################
  
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
          recipe(compressive_strength ~ ., train) |>
          step_normalize(all_predictors()),
        poly_recipe =
          recipe(compressive_strength ~ ., train) |>
          step_normalize(all_predictors()) |>
          step_poly(all_predictors()) |>
          step_interact(~ all_predictors():all_predictors()),
        keras_recipe =
          recipe(compressive_strength ~ ., train) |>
          step_center(all_predictors(), -all_outcomes()) |>
          step_scale(all_predictors(), -all_outcomes()) |>
          prep()
      )
  ),
  # ### TODO: model specification: make this environment variable
  tgt(models, {
    list( # empty arg gets filled with tune()
      linear_reg_spec = mod(linear_reg, glmnet, penalty=, mixture=),
      mars_spec = mod(mars, earth, prod_degree=),
      svm_r_spec = mod(svm_rbf, kernlab, cost=, rbf_sigma=),
      svm_p_spec = mod(svm_poly, kernlab, cost=, degree=),
      knn_spec = mod(nearest_neighbor, kknn, neighbors=, dist_power=, weight_fun=),
      cart_spec = mod(decision_tree, rpart, cost_complexity=, min_n=),
      ### FIXME: bagged cart is currently broken. Renamed function?
      # bag_cart_spec = bag_mars() |>
      #   set_engine("earth", time = 50L) |>
      #   set_mode("regression"),
      rf_spec = mod(rand_forest, ranger, mtry=, min_n=, trees = 1000),
      xgb_spec = mod(boost_tree, xgboost,
                     tree_depth=, learn_rate=, loss_reduction=,
                     min_n=, sample_size=, trees=),
      cubist_spec =
        cubist_rules(committees = tune(), neighbors = tune()) |>
        set_engine("Cubist")
    )
  }
  ),
  tgt(flows, {
    list(
      normalized = workflow_set(
        list(
          normalized = recipes$normalized_recipe),
        list(SVM_radial = models$svm_r_spec,
          SVM_poly = models$svm_p_spec,
          KNN = models$knn_spec)
      ),
      no_pre_proc = workflow_set(
        list(
          simple = workflow_variables(compressive_strength,
                                      everything())
        ),
        list(MARS = models$mars_spec,
        CART = models$cart_spec,
        ### FIXME: CART_bagged is currently bugged
        #CART_bagged = models$bag_cart_spec,
        RF = models$rf_spec,
        boosting = models$xgb_spec,
        Cubist = models$cubist_spec
      )),
      with_features = workflow_set(
        list(full_quad = recipes$poly_recipe),
        list(
          linear_reg = models$linear_reg_spec,
          KNN = models$knn_spec)
      )
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
  }),
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
  # tgt(ranking, {
  #  results |>
  #   filter(.metric == "rmse") |>
  #  select(model, .config, rmse = mean, rank)
  # }, packages = c("dplyr"))
  ## TODO: results plotting to package visualizaion.R wrapper
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
      extract_workflow_set_result("boosting") |>
      select_best(metric = "rmse")
  }),
  tgt(winners_post_test, {
    results |>
      extract_workflow("boosting") |>
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
  )
  
  #####################
  ####   Keras    #####
  #####################
  #' @note keras neural network starts here
  # ,
  # tar_target(
  #   keras_rec,
  #   prepare_recipe(train),
  #   format = "qs",
  #   deployment = "main"
  # ),
  # tar_target(
  #   units,
  #   c(16, 32),
  #   deployment = "main"
  # ),
  # tar_target(
  #   act,
  #   c("relu", "sigmoid"),
  #   deployment = "main"
  # ),
  # tar_target(
  #   run,
  #   test_model(init, keras_rec, units1 = units, act1 = act),
  #   pattern = cross(units, act),
  #   format = "fst_tbl"
  # ),
  # tar_target(
  #   best_run,
  #   run %>%
  #     top_n(1, accuracy) %>%
  #     head(1),
  #   format = "fst_tbl",
  #   deployment = "main"
  # ),
  # tar_target(
  #   best_model,
  #   train_best_model(best_run, keras_rec),
  #   format = "keras"
  # )
  
  #####################
  ####  Bookdown  #####
  #####################
  ### FIXME: pipeline does not renew if _bookdown.yml changes
  # Workaround: delete "book" object from _targets/object/
  ,
  tar_files(
    paths,
    dir("data", full.names = TRUE)[2]
  ),
  tgt(
    raw_data,
    read_csv(paths, col_types = cols()),
    pattern = map(paths)
  ),
  tgt(
    data,
    raw_data %>%
      mutate(Ozone = replace_na(Ozone, mean(Ozone, na.rm = TRUE))),
    pattern = map(raw_data)
  ),
  tgt(
    hist,
    create_plot(data),
    pattern = map(data)),
  tgt(
    fit,
    lm(Ozone ~ Wind + Temp, data),
    pattern = map(data)),
  
  tar_file(template, "inst/template.Rmd"),
  
  tgt(
    report,
    rmarkdown::render(
      template,
      params = list(
        histogram = hist,
        model = fit,
        title = as.character(tar_name())
      ),
      output_file = as.character(tar_name()),
      output_dir = "_chapters") %>%
      change_ext(inext = "md", outext = "Rmd"),
    pattern = map(hist, fit),
    format = "file"
  ),
  
  tar_file(index, "index.Rmd"),
  
  tar_target(
    book,
    render_with_deps(index, report)
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
