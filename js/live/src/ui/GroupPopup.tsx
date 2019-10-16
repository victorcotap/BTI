import React from 'react';
import {Popup} from "react-mapbox-gl";

import Group from '../model/group';

const stylePopup = {
    color: 'black',
    borderRadius: '10px'
}

interface GroupPopupProps {
    group: Group,
    closePopup: () => void
}

const GroupPopup: React.StatelessComponent<GroupPopupProps> = ({children, group, closePopup}) => {
    const altitude = group.height * 3.28084;
    return (
        <Popup key={group.type} coordinates={[group.longitude, group.latitude]} offset={15}>
            <div style={stylePopup}>
                <h1>{group.displayName}</h1>
                <span>{group.LLDMS}</span><br />
                <span>{group.MGRS}</span><br />
                <span>{group.LLDDM}</span><br />
                <span><b>Altitude: </b> {altitude.toFixed(0)} feet</span><br />
                <span><b>HDG: </b>{group.heading}</span><br />
                <button onClick={closePopup}>Close</button>
            </div>
        </Popup>
    )
}

export default GroupPopup
