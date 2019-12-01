import React from 'react';
import { Layer } from "react-mapbox-gl";
import Mapboxgl from 'mapbox-gl';

export function injectDefaultSources(map: Mapboxgl.Map) {
    map.addSource('Sochi-App-Img', {
        type: 'image',
        url: '/images/Sochi-App-06.png',
        coordinates: [
            [39.7020395, 43.6745508],
            [40.1952793, 43.6438719],
            [40.147097, 43.1336884],
            [39.6525725, 43.1663879],
        ]
    });
}

export default function renderChartLayers() {
    let approachchartLayers = []
    const sochiLayer = (
        <Layer
            key="Sochi-App"
            id="Sochi-App"
            sourceId="Sochi-App-Img"
            type="raster"
            paint={{ "raster-opacity": 0.7 }}
        />
    )
    approachchartLayers.push(sochiLayer)
    return approachchartLayers
}