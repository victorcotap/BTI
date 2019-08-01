import React from 'react';


import Group, { category, coalition } from '../model/group';
import { Layer, Feature } from "react-mapbox-gl";


function renderGroup(group: Group, clickHandler: (group: Group) => void) {
    const key = `${group.type}${group.latitude}${group.longitude}`;
    return (
        <Feature 
            coordinates={[group.longitude, group.latitude]} 
            properties={group} 
            key={key}
            onClick={(mapWithEvent) => {
                    clickHandler(group);
                }
            }
        />
    );
}

export default function renderLayers(groups: Group[], clickHandler: (group: Group) => void) {
    const redGroundGroups = groups.filter((group) => 
        group.category === category.Ground && group.coalition === coalition.Red).map((group) => renderGroup(group, clickHandler));
    const redGroundLayer = (<Layer
        key="redGroundLayer"
        type="symbol"
        id="redGroundLayer"
        layout={{ "icon-image": "fi-main-2" }}>
        {redGroundGroups}
    </Layer>)
    const unitsLayers = [redGroundLayer]

    const redAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Red).map((group) => renderGroup(group, clickHandler));
    const redAirLayer = (<Layer
        key="redAirLayer"
        type="symbol"
        id="redAirLayer"
        layout={{ "icon-image": "nz-state-2" }}>
        {redAirGroups}
    </Layer>)
    unitsLayers.push(redAirLayer)

    const blueGroundGroups = groups.filter((group) => group.category === category.Ground && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueGroundLayer = (<Layer
        key="blueGroundLayer"
        type="symbol"
        id="blueGroundLayer"
        layout={{ "icon-image": "hu-state-2" }}>
        {blueGroundGroups}
    </Layer>)
    unitsLayers.push(blueGroundLayer)

    const blueAirGroups = groups.filter((group) => group.category === category.Airplane && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueAirLayer = (<Layer
        key="blueAirLayer"
        type="symbol"
        id="blueAirLayer"
        layout={{ "icon-image": "airfield-15" }}>
        {blueAirGroups}
    </Layer>)
    unitsLayers.push(blueAirLayer);

    const blueShipGroups = groups.filter((group) => group.category === category.Ship && group.coalition === coalition.Blue).map((group) => renderGroup(group, clickHandler));
    const blueShipLayer = (<Layer
        key="blueShipLayer"
        type="symbol"
        id="blueShipLayer"
        layout={{ "icon-image": "ro-county-4" }}>
        {blueShipGroups}
    </Layer>)
    unitsLayers.push(blueShipLayer)

    return unitsLayers;
}