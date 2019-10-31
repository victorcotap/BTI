import React, { CSSProperties } from 'react';
import Waypoint from '../model/waypoint';
import {distanceBetween, bearingBetween, waypointToDMM} from '../utils/coordinatesUtils';


interface FlightPlannerProps {
    route: Waypoint[],
    onClearRoute: () => void,
    onSwapWaypoint: (waypointIndex: number, newWaypointIndex: number) => void,
    onDeleteWaypoint: (waypointIndex: number) => void,
};

const styleButton: CSSProperties = {
    margin: "0 10px 0 0",
    backgroundColor: "#ffffff",
    color: "#333333",
    height: "2rem",
    border: "none"
}
const styleCell: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: 'space-between',
    padding: "0 0 2px 0",
    borderBottom: "1px solid rgba(255,255,255,0.2)",
}

const styleColumn: CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
}



const FlightPlanner: React.StatelessComponent<FlightPlannerProps> = ({ children, route, onClearRoute, onSwapWaypoint, onDeleteWaypoint }) => {
    const waypointList = route.map((waypoint, index) => {
        const dmmStrings = waypointToDMM(waypoint);
        return (
            <div style={styleCell} key={index}>
                <div style={styleColumn}>
                    {index > 0 ? <button onClick={() => onSwapWaypoint(index, index - 1)}>{'<'}</button> : undefined}
                    <button onClick={() => onDeleteWaypoint(index)}>x</button>
                    {index < route.length - 1 ? <button onClick={() => onSwapWaypoint(index, index + 1)}>></button> : undefined}
                </div>
                <div style={styleColumn}>
                    <span>{dmmStrings.latString}</span>
                    <span>{dmmStrings.lonString}</span>
                </div>
                <span style={{minWidth: '15%'}}>{index > 0 ? `${bearingBetween(waypoint, route[index - 1]).toFixed(0)}°` : undefined}</span>
                <span style={{minWidth: '15%'}}>{index > 0 ? `${distanceBetween(waypoint, route[index - 1]).toFixed(1)} nm` : undefined}</span>
                <span style={{minWidth: '15%'}}>{(waypoint.elevation * 3.28084).toFixed(0)} ft</span>
            </div>
        );
    });
    return (
        <div>
            <p>Everything with this side panel open is WIP, use at your own risk<br />Start clicking on the map to add waypoints</p>
            {route.length > 0 ? <button style={styleButton} onClick={onClearRoute}>Clear Route</button> : undefined}
            {waypointList}
            <p>Export to DCS: Continue to Ask ED to release their data cartridge for Multiplayer </p>
        </div>
    );
};

export default FlightPlanner
