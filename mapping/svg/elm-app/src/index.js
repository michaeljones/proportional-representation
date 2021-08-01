import "./main.css";
import { Elm } from "./Main.elm";
import * as serviceWorker from "./serviceWorker";

const data = require("./uk-constituencies-2015.json");

console.log(data);

// const features = data.features.filter(feature => feature.type === "Polygon").map(feature => ({ ...feature, coordinates: feature.coordinates.map(coord => ({x: coord[0], y: coord[1]}))}))
const features = data.features.map((feature) => {
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
    flags: { features },
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
