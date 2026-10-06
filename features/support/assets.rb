BeforeAll do
  # Build the esbuild + Dart Sass bundles so Propshaft can serve them in feature
  # specs. In CI the Docker image already precompiled them (owned by root), so
  # only build when the output is missing, e.g. a local run.
  unless File.exist?(Rails.root.join("app", "assets", "builds", "application.js"))
    system("yarn build && yarn build:css", exception: true)
  end
end
