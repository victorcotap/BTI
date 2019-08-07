import React from 'react';

import Group, { category, coalition, attributes } from '../model/group';
import { Layer, Feature } from "react-mapbox-gl";

import BlueAir from '../assets/Blue-Air.png';
import BlueHelo from '../assets/Blue-Helo.png';

import BlueGround from '../assets/Blue-Ground.png';
import BlueCarrier from '../assets/Blue-Carrier.png';

import RedAir from '../assets/Red-Air.png'
import RedHelo from '../assets/Red-Helo.png'

import RedSAM from '../assets/Red-SAM.png';
import RedAAA from '../assets/Red-AAA.png';
import RedAPC from '../assets/Red-APC.png';
import RedArmor from '../assets/Red-Armor.png';
import RedArtillery from '../assets/Red-Artillery.png';
import RedInfantry from '../assets/Red-Infantry.png';
import RedFortifications from '../assets/Red-Fortifications.png';

import RedGround from '../assets/Red-Ground.png';

function renderImage(imageSrc: string): HTMLImageElement {
    const image = new Image(35, 35);
    image.src = imageSrc;
    return image;
}

function renderGroup(group: Group, clickHandler: (group: Group) => void) {
    const key = `${group.type}${group.latitude}${group.longitude}`;
    return (
        <Feature
            coordinates={[group.longitude, group.latitude]}
            properties={group}
            key={key}
            onClick={(mapWithEvent) => {
                clickHandler(group);
            }}
        />
    );
}

function renderGroupsLayer(groups: JSX.Element[], image: HTMLImageElement, imageKey: string) {
    return (<Layer
        key={imageKey}
        type="symbol"
        id={imageKey}
        images={[imageKey, image]}
        layout={{ "icon-image": imageKey }}>
        {groups}
    </Layer>);
}

export default function renderLayers(groups: Group[], clickHandler: (group: Group) => void) {
    const blueGroups = groups.filter((group) => group.alive === true && group.coalition === coalition.Blue);
    const redGroups = groups.filter((group) => group.alive === true && group.coalition === coalition.Red);
    const redGroupsGround = redGroups.filter((group) => group.category === category.Ground);

    const blueGroundGroups = blueGroups.filter((group) => group.category === category.Ground).map((group) => renderGroup(group, clickHandler));
    const blueGroundLayer = renderGroupsLayer(blueGroundGroups, renderImage(BlueGround), "Blue-Ground")
    const unitsLayers = [blueGroundLayer]

    const blueAirGroups = blueGroups.filter((group) => group.category === category.Airplane).map((group) => renderGroup(group, clickHandler));
    const blueAirLayer = renderGroupsLayer(blueAirGroups, renderImage(BlueAir), "Blue-Air")
    unitsLayers.push(blueAirLayer);

    const blueHeloGroups = blueGroups.filter((group) => group.category === category.Helicopter).map((group) => renderGroup(group, clickHandler));
    const blueHeloLayer = renderGroupsLayer(blueHeloGroups, renderImage(BlueHelo), "Blue-Helo")
    unitsLayers.push(blueHeloLayer);

    const blueShipGroups = blueGroups.filter((group) => group.category === category.Ship).map((group) => renderGroup(group, clickHandler));
    const blueShipLayer = renderGroupsLayer(blueShipGroups, renderImage(BlueCarrier), "Blue-Carrier")
    unitsLayers.push(blueShipLayer)


    const redAirGroups = redGroups.filter((group) => group.category === category.Airplane).map((group) => renderGroup(group, clickHandler));
    const redAirLayer = renderGroupsLayer(redAirGroups, renderImage(RedAir), "Red-Air")
    unitsLayers.push(redAirLayer)

    const redHeloGroups = redGroups.filter((group) => group.category === category.Helicopter).map((group) => renderGroup(group, clickHandler));
    const redHeloLayer = renderGroupsLayer(redHeloGroups, renderImage(RedHelo), "Red-Helo")
    unitsLayers.push(redHeloLayer)

    const redSAMGroups = redGroupsGround.filter((group) => group.attributes[attributes.SAM] || group.attributes[attributes.SAMRelated]).map((group) => renderGroup(group, clickHandler));
    const redSAMLayer = renderGroupsLayer(redSAMGroups, renderImage(RedSAM), "Red-SAM")
    unitsLayers.push(redSAMLayer);

    const redAAAGroups = redGroupsGround.filter((group) => group.attributes[attributes.AAA]).map((group) => renderGroup(group, clickHandler));
    const redAAALayer = renderGroupsLayer(redAAAGroups, renderImage(RedAAA), "Red-AAA")
    unitsLayers.push(redAAALayer);

    const redAPCGroups = redGroupsGround.filter((group) => group.attributes[attributes.APC] || group.attributes[attributes.LightArmor]).map((group) => renderGroup(group, clickHandler));
    const redAPCLayer = renderGroupsLayer(redAPCGroups, renderImage(RedAPC), "Red-APC")
    unitsLayers.push(redAPCLayer);

    const redArmorGroups = redGroupsGround.filter((group) => group.attributes[attributes.Armor] || group.attributes[attributes.HeavyArmor]).map((group) => renderGroup(group, clickHandler));
    const redArmorLayer = renderGroupsLayer(redArmorGroups, renderImage(RedArmor), "Red-Armor")
    unitsLayers.push(redArmorLayer)

    const redArtilleryGroups = redGroupsGround.filter((group) => group.attributes[attributes.Artillery]).map((group) => renderGroup(group, clickHandler));
    const redArtilleryLayer = renderGroupsLayer(redArtilleryGroups, renderImage(RedArtillery), "Red-Artillery")
    unitsLayers.push(redArtilleryLayer)

    const redInfantryGroups = redGroupsGround.filter((group) => group.attributes[attributes.Infantry]).map((group) => renderGroup(group, clickHandler));
    const redInfantryLayer = renderGroupsLayer(redInfantryGroups, renderImage(RedInfantry), "Red-Infantry")
    unitsLayers.push(redInfantryLayer)

    const redFortificationsGroups = redGroupsGround.filter((group) => group.attributes[attributes.Fortifications]).map((group) => renderGroup(group, clickHandler));
    const redFortificationsLayer = renderGroupsLayer(redFortificationsGroups, renderImage(RedFortifications), "Red-Fortifications")
    unitsLayers.push(redFortificationsLayer)

    const redGroundGroups = redGroupsGround.filter((group) => group.attributes[attributes.Trucks] || group.attributes[attributes.Cars]).map((group) => renderGroup(group, clickHandler));
    const redGroundLayer = renderGroupsLayer(redGroundGroups, renderImage(RedGround), "Red-Ground")
    unitsLayers.push(redGroundLayer);

    return unitsLayers;
}