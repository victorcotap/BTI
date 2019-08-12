import React from 'react';
import {Popup} from "react-mapbox-gl";

import Group from '../model/group';

import './map.css';

interface GroupPopupProps {
    group: Group,
    closePopup: () => void
}

const GroupPopup: React.StatelessComponent<GroupPopupProps> = ({children, group, closePopup}) => {
    return (
        <Popup key={group.type} coordinates={[group.longitude, group.latitude]} offset={15}>
            <div className="PopupText">
                <h1>{group.displayName}</h1>
                <span>{group.LLDMS}</span><br />
                <span>{group.MGRS}</span><br />
                <span>{group.LLDDM}</span><br />
                <span><b>Altitude: </b> {group.height.toFixed(1)} meters</span><br />
                <span><b>HDG: </b>{group.heading}</span><br />
                <button onClick={closePopup}>Close</button>
            </div>
        </Popup>
    )
}

export default GroupPopup
