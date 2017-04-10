# Custom directories with classes and modules you want to be autoloadable.
Rails.application.config.eager_load_paths += Dir[
    "#{Rails.root}/lib"
]
