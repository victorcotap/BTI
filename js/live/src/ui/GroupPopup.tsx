import React from 'react';
import {Popup} from "react-mapbox-gl";

import Group from '../model/group';

import './map.css';

interface GroupPopupProps {
    group: Group
}

const GroupPopup: React.StatelessComponent<{group: Group}> = ({children, group}) => {
    //TODO convert to different lat lon formats


    return (
        <Popup key={group.type} coordinates={[group.longitude, group.latitude]} offset={15}>
            <div className="PopupText">
                <h2>{group.type}</h2>
                <span>Lon: {group.longitude} Lat: {group.latitude}</span><br />
                <span>{group.height} m</span><br />
                <span>HDG {group.heading}</span>
            </div>
        </Popup>
    )
}

export default GroupPopup