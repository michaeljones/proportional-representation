import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

import votingData from "./votes.js";

const geojson = require("./uk-constituencies-2015.json");

const features = geojson.features.map((feature) => {
    if (feature.geometry.type === "Polygon") {
        return {
            name: feature.properties.pcon15nm,
            coordinates: [
                feature.geometry.coordinates.map((loop) =>
                    loop.map((coord) => ({ x: coord[0], y: coord[1] }))
                ),
            ],
        };
    } else {
        return {
            name: feature.properties.pcon15nm,
            coordinates: feature.geometry.coordinates.map((loop) =>
                loop.map((innerLoop) => innerLoop.map((coord) => ({ x: coord[0], y: coord[1] })))
            ),
        };
    }
});

console.log(features);

Elm.Main.init({
    node: document.getElementById("root"),
    flags: { features, votesCsv: votingData },
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
