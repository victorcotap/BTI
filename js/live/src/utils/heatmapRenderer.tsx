import React from 'react';

import Group, { coalition, category } from '../model/group';
import { Layer, Feature } from "react-mapbox-gl";

export default function renderHeatmap(groups: Group[]) {
    const layerPaint = {
        'heatmap-weight': {
            property: 'priceIndicator',
            type: 'exponential',
            stops: [[0, 0], [5, 2]]
        },

        // Increase the heatmap color weight weight by zoom level
        // heatmap-ntensity is a multiplier on top of heatmap-weight
        "heatmap-intensity": [
            "interpolate",
            ["linear"],
            ["zoom"],
            0, 1,
            9, 2
        ],
        // Color ramp for heatmap.  Domain is 0 (low) to 1 (high).
        // Begin color ramp at 0-stop with a 0-transparancy color
        // to create a blur-like effect.
        "heatmap-color": [
            "interpolate",
            ["linear"],
            ["heatmap-density"],
            0, "rgba(33,102,172,0)",
            0.2, "rgb(103,169,207)",
            0.4, "rgb(209,229,240)",
            0.6, "rgb(253,219,199)",
            0.8, "rgb(239,138,98)",
            1, "rgb(178,24,43)"
        ],
        // Adjust the heatmap radius by zoom level
        "heatmap-radius": [
            "interpolate",
            ["linear"],
            ["zoom"],
            0, 1,
            9, 23
        ],
        "heatmap-opacity": [
            "interpolate",
            ["linear"],
            ["zoom"],
            10, 1,
            19, 0
        ],
    };

    const features = groups.filter((group: Group) => group.coalition === coalition.Red &&
        group.category !== category.Airplane &&
        group.category !== category.Helicopter &&
        group.alive === true
        ).map((group: Group) => {
        const key = `heat${group.type}${group.latitude}${group.longitude}`;
        return (
            <Feature key={key} properties={group} coordinates={[group.longitude, group.latitude]} />
        )
    })
    return (
        <Layer key="groupHeatmap" type="heatmap" id="groupHeatmap" paint={layerPaint}>
            {features}
        </Layer>
    )
}