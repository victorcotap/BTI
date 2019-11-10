import React, { CSSProperties } from 'react';
import ReactMapboxGl from "react-mapbox-gl";
import MapboxGl, { LngLat } from 'mapbox-gl';
import DmsCoordinates from 'dms-conversion';

import Group, { isGroup } from '../model/group';
import Waypoint, { WaypointType } from '../model/waypoint';
import renderLayers from '../utils/groupsRenderer';
import renderHeatmap from '../utils/heatmapRenderer';
import renderRoute from '../utils/routeRenderer';
import {coordinatesToDMM} from '../utils/coordinatesUtils';
import GroupPopup from './GroupPopup';

import config from '../config.json';

const styleMapContainer: CSSProperties = {
    width: '100%',
    height: '100%',
    position: "relative",
    overflow: "hidden"
};

const styleCoordBox: CSSProperties = {
    backgroundColor: "#000000",
    opacity: 0.7,
    padding: "10px",
    borderRadius: "10px",
    color: "#ffffff",
    boxSizing: "border-box",
    position: "absolute",
    zIndex: 2,
    left: 10,
    bottom: 5,
};

const Mapbox = ReactMapboxGl({
    accessToken: "pk.eyJ1IjoidmljdG9yY290YXAiLCJhIjoiY2p4eTdvZjRhMDdpejNtb2FmenRvenk0cCJ9.lf2sq-jELqUvTyPil0tWRA",
    antialias: true,
});

interface Props {
    showHeatmap: boolean,
    showBlue: boolean,
    showAirDefenses: boolean,
    showArmor: boolean,
    showGround: boolean,
    route?: Waypoint[],
    onSelectMapPoint: (point: LngLat, type: WaypointType, name?: string) => void
}

interface State {
    center: [number, number],
    currentGroups: Group[],
    selectedGroup?: Group,
    selectedPoint?: LngLat,
}

const defaultZoom: [number] = [7];

export default class Map extends React.Component<Props> {
    state: State = {
        center: [55.415474, 26.078377],
        currentGroups: Array<Group>(),
    };
    lastLocation?: [number, number] = undefined;
    private underlyingMap: MapboxGl.Map | undefined;


    private async fetchData() {
        return fetch(config.coreTunnel + "/live", {
            method: 'GET',
            mode: 'cors',
            headers: {
                'Content-Type': 'application/json',
            },
        })
    }
    async refreshData() {
        try {
            const newData = await this.fetchData()
            const newJSON = await newData.json()
            const { currentGroups } = newJSON;
            const groups: Group[] = currentGroups;
            if (groups) {
                this.setState({ currentGroups: groups })
            }
        } catch (error) {
            console.log(error);
        }
    }
    private groupClickHandler(group: Group) {
        this.setState({ selectedGroup: group });
    }
    private groupPopupClose() {
        this.setState({ selectedGroup: undefined });
    }
    private groupAddToFlightPlan(group: Group) {
        this.props.onSelectMapPoint(new LngLat(group.longitude, group.latitude), WaypointType.DMPI, group.displayName);
    }
    private mapMoveEnd(map: MapboxGl.Map, event: any) {
        const center = map.getCenter()
    }

    private mapMouseClick(map: MapboxGl.Map, event: any) {
        let selectedPoint = event.lngLat

        const groupFeature = map.queryRenderedFeatures(event.point)[0];
        if (groupFeature && isGroup(groupFeature.properties)) {
            const group: Group = groupFeature.properties as Group;
            selectedPoint = { lng: group.longitude, lat: group.latitude };
        } else {
            this.props.onSelectMapPoint(selectedPoint, WaypointType.waypoint);
        }

        this.setState({ selectedPoint });
    }

    componentDidMount() {
        this.refreshData();
        setInterval(() => this.refreshData(), 30000);
    }

    render() {
        const { showAirDefenses, showArmor, showBlue, showGround, showHeatmap, route } = this.props;
        const { selectedGroup, selectedPoint } = this.state;

        if (!this.state.currentGroups.length) {
            return (
                <h2>Loading...</h2>
            )
        }

        const groupLayers = renderLayers(
            this.state.currentGroups,
            (group: Group) => this.groupClickHandler(group),
            { showAirDefenses, showArmor, showBlue, showGround });
        const heatmapLayer = renderHeatmap(this.state.currentGroups);
        const routeLayer = renderRoute(route);

        let popup = undefined;
        if (selectedGroup) {
            popup = (
                <GroupPopup
                    group={selectedGroup}
                    closePopup={() => this.groupPopupClose()}
                    addToFlightPlan={(group) => this.groupAddToFlightPlan(group)}
                />
            );
        }

        let cursorCoordinates = (
            <div style={styleCoordBox}><span>Click on the map to get coordinates</span></div>
        );
        if (selectedPoint) {
            const dmmStrings = coordinatesToDMM(selectedPoint);
            cursorCoordinates = (
                <div style={styleCoordBox}>
                    <span>Latitude {selectedPoint.lat.toFixed(6)}</span><br />
                    <span>Longitude {selectedPoint.lng.toFixed(6)}</span><br />
                    <span>{dmmStrings.latString} {dmmStrings.lonString}</span>
                </div>
            )
        }

        return (
            <div style={styleMapContainer}>
                <Mapbox
                    style={"mapbox://styles/victorcotap/cjypbpdul4n6j1cmpkt13719b"}
                    center={this.state.center}
                    zoom={defaultZoom}
                    onMoveEnd={(map, event) => this.mapMoveEnd(map, event)}
                    onClick={(map, event) => this.mapMouseClick(map, event)}
                    containerStyle={{
                        width: "100%",
                        height: "100%"
                    }}>
                    {showHeatmap ? heatmapLayer : undefined}
                    {groupLayers}
                    {routeLayer}
                    {/* noop */}
                    {popup}
                </Mapbox>
                {cursorCoordinates}
            </div>
        )
    }
}
