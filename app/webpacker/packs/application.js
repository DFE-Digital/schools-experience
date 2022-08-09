require.context("govuk-frontend/govuk/assets");
require.context('../images', true);

import "../stylesheets/application.scss";

import { initAll } from "govuk-frontend";
initAll();

import "@stimulus/polyfills";
import "custom-event-polyfill";
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers";

const application = Application.start();
const context = require.context("controllers", true, /.js$/);
application.load(definitionsFromContext(context));
