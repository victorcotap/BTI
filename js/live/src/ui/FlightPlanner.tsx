import React, { CSSProperties } from 'react';
import Waypoint, { WaypointType } from '../model/waypoint';
import {distanceBetween, bearingBetween, coordinatesToDMM, totalRouteNm} from '../utils/coordinatesUtils';
import { LngLat } from 'mapbox-gl';


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
    border: "none",
    borderRadius: "0.5rem",
}
const styleButtonPill: CSSProperties = {
    borderRadius: "100px",
    border: "none",
}
const styleWaypointList: CSSProperties = {
    marginTop: '10px',
    marginBottom: '5px',
}

const styleCell: CSSProperties = {
    display: "flex",
    flexDirection: "row",
    justifyContent: 'space-between',
    padding: "2px 0 2px 5px",
    borderBottom: "1px solid rgba(255,255,255,0.2)",
}
const styleCellWaypoint: CSSProperties = {
    color: "black",
}
const styleCellDMPI: CSSProperties = {
    color: "white",
}

const styleColumn: CSSProperties = {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-around',
}


const FlightPlanner: React.StatelessComponent<FlightPlannerProps> = ({ children, route, onClearRoute, onSwapWaypoint, onDeleteWaypoint }) => {
    const waypointList = route.map((waypoint, index) => {
        const dmmStrings = coordinatesToDMM(new LngLat(waypoint.longitude, waypoint.latitude));
        const styleWaypointType = waypoint.type === WaypointType.waypoint ? styleCellWaypoint : styleCellDMPI;
        return (
            <div style={{...styleCell, ...styleWaypointType, backgroundColor: waypoint.color}} key={index}>
                <div style={styleColumn}>
                    {index > 0 ? <button style={styleButtonPill} onClick={() => onSwapWaypoint(index, index - 1)}>▲</button> : undefined}
                    <button style={styleButtonPill} onClick={() => onDeleteWaypoint(index)}>x</button>
                    {index < route.length - 1 ? <button style={styleButtonPill} onClick={() => onSwapWaypoint(index, index + 1)}>▼</button> : undefined}
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
    const totalRoute = totalRouteNm(route);
    return (
        <div>
            {!route.length ? <p>Start clicking on the map to add waypoints</p> : undefined}
            {route.length > 0 ? <button style={styleButton} onClick={onClearRoute}>Clear Route</button> : undefined}
            <div style={styleWaypointList}>{waypointList}</div>
            {route.length > 0 ? <p>Total distance: {totalRoute.toFixed(0)} nm</p> : undefined}
            <p>Export to DCS: Continue to Ask ED to release their data cartridge for Multiplayer </p>
        </div>
    );
};

export default FlightPlanner
