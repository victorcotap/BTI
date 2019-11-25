import React from 'react';
import { Layer, Source } from "react-mapbox-gl";
import Mapboxgl from 'mapbox-gl';

export function renderSources() {
    let sources = [];
    const sochiSource = (
        <Source
            key="Sochi-App-Img"
            id="Sochi-App-Img"
            type="image"
            url="http://data.throughtheinferno.com/image/Sochi-App-06.png"
            coordinates={[
                [39.717797, 43.606915],
                [40.168803, 43.618235],
                [40.141029, 43.289052],
                [39.691684, 43.281618],
            ]}
        />
    )
    console.log({sochiSource});
    sources.push(sochiSource)
    return sources
}

export function testSource(map: Mapboxgl.Map) {
    map.addSource('Sochi-App-Img', {
        type: 'image',
        url: 'http://data.throughtheinferno.com/image/Sochi-App-06.png',
        coordinates: [
            [39.717797, 43.606915],
            [40.168803, 43.618235],
            [40.141029, 43.289052],
            [39.691684, 43.281618],
        ]
    });
}

export default function renderChartLayers() {
    let chartLayers = []
    const sochiLayer = (
        <Layer
            key="Sochi-App"
            id="Sochi-App"
            sourceId="Sochi-App-Img"
            type="raster"
            paint={{ "raster-opacity": 0.8 }}
        />
    )
    chartLayers.push(sochiLayer)
    return chartLayers
}