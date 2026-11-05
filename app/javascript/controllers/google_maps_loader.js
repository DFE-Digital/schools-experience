import { importLibrary, setOptions } from "@googlemaps/js-api-loader";

let configuredApiKey = null;

export async function importGoogleMapsLibrary(apiKey, library) {
  if (configuredApiKey === null) {
    setOptions({ key: apiKey });
    configuredApiKey = apiKey;
  } else if (configuredApiKey !== apiKey) {
    throw new Error("Google Maps API key changed after loader initialisation");
  }

  return importLibrary(library);
}

export function resetGoogleMapsLoaderState() {
  configuredApiKey = null;
}
