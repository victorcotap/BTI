import React from 'react';
import Waypoint from '../model/waypoint';
import { Feature, Layer } from 'react-mapbox-gl';

const lineLayout = {
    'line-cap': 'round' as 'round',
    'line-join': 'round' as 'round'
};

const linePaint = {
    'line-color': '#FF00FF',
    'line-width': 5,
    'line-opacity': 0.45,
};

const circlePaint = {
    'circle-radius': 5,
    'circle-color': '#0000FF',
    'circle-opacity': 0.5,
};


export default function renderRoute(route?: Waypoint[]) {
    if (!route) { return undefined }

    const lineCoordinates = route.map((waypoint) => {
        return [waypoint.longitude, waypoint.latitude]
    });
    const lineLayer = (
        <Layer key="routeLineLayer" type="line" layout={lineLayout} paint={linePaint} >
            <Feature key="routeLineFeature" coordinates={lineCoordinates} />
        </Layer>
    )
    const circleFeatures = route.map((waypoint) => {
        return (<Feature
            key={`circle${waypoint.longitude}${waypoint.latitude}`}
            coordinates={[waypoint.longitude, waypoint.latitude]}
        />)
    });
    const circleLayer = (
        <Layer key="routeCircleLayer" type="circle" paint={circlePaint} >
            {circleFeatures}
        </Layer>
    )

    return [lineLayer, circleLayer];
}