box::use(
  targets[
    #plot = tar_visnetwork,
    tgt = tar_target,
    ...
  ],
  ML[...]
)

#tar_option_set(packages = c("rlang"))

#' key project modelling pipeline
#' 
list(
  ### TODO: data input step
  ### TODO: validate data step
  ### TODO: data preparation step
  tgt(
    data, {
      e = new.env()
      add_splits(e, mtcars, prop = .75)
    }
  )
  ### TODO: data pre-processing step [recipe specification]
  ### TODO: model specification step [parsnip specification]
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
