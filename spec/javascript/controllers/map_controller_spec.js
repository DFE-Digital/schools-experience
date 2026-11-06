import { importLibrary, setOptions } from "@googlemaps/js-api-loader";
import MapController from "map_controller.js";
import { resetGoogleMapsLoaderState } from "google_maps_loader.js";

jest.mock("@googlemaps/js-api-loader", () => ({
  importLibrary: jest.fn(),
  setOptions: jest.fn(),
}));

describe("MapController", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    resetGoogleMapsLoaderState();
    importLibrary.mockResolvedValue({});
  });

  it("initialises the Maps library with the configured API key", async () => {
    const drawMap = jest.fn();
    const controllerContext = {
      apiKeyValue: "KEY",
      drawMap,
    };

    await MapController.prototype.initMap.call(controllerContext);

    expect(setOptions).toHaveBeenCalledWith({ key: "KEY" });
    expect(importLibrary).toHaveBeenCalledWith("maps");
    expect(drawMap).toHaveBeenCalled();
  });

  it("draws the map after the Maps library loads", async () => {
    const drawMap = jest.fn();
    const controllerContext = {
      apiKeyValue: "KEY",
      drawMap,
    };

    await MapController.prototype.initMap.call(controllerContext);

    expect(drawMap).toHaveBeenCalledTimes(1);
  });
});
