import React, { CSSProperties } from 'react';
import ReactMapboxGl from "react-mapbox-gl";
import MapboxGl, { LngLat } from 'mapbox-gl';
import DmsCoordinates from 'dms-conversion';

import Group, { isGroup } from '../model/group';
import Waypoint, { WaypointType } from '../model/waypoint';
import renderLayers from '../utils/groupsRenderer';
import renderChartLayers, { injectDefaultSources } from '../utils/chartRenderer';
import renderHeatmap from '../utils/heatmapRenderer';
import renderRoute from '../utils/routeRenderer';
import { coordinatesToDMM } from '../utils/coordinatesUtils';
import FilterBox from './FilterBox';
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

const mapCenters: { [key: string]: [number, number] } = {
    'PG': [55.415474, 26.078377],
    'CCS': [41.139825, 42.659296],
    'NTTR': [-115.0306085, 36.235341],
}

interface Props {
    route?: Waypoint[],
    onSelectMapPoint: (point: LngLat, type: WaypointType, name?: string) => void
}

interface State {
    center: [number, number],
    currentGroups: Group[],
    selectedGroup?: Group,
    selectedPoint?: LngLat,
    showHeatmap: boolean,
    showBlue: boolean,
    showAirDefenses: boolean,
    showArmor: boolean,
    showGround: boolean,
    showApproachChart: boolean,
}

const defaultZoom: [number] = [7];

export default class Map extends React.Component<Props> {
    state: State = {
        center: mapCenters[config.map],
        currentGroups: Array<Group>(),
        showHeatmap: true,
        showBlue: true,
        showAirDefenses: true,
        showArmor: true,
        showGround: true,
        showApproachChart: false,
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

    private onFilterSelection = (filterKey: string, value: boolean) => {
        this.setState({ [filterKey]: value });
    }

    private mapLoaded(map: MapboxGl.Map) {
        injectDefaultSources(map);
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
        const { route } = this.props;
        const { selectedGroup, selectedPoint, showAirDefenses, showArmor, showBlue, showGround, showHeatmap, showApproachChart, } = this.state;

        if (!this.state.currentGroups.length) {
            return (
                <div>
                    <h2>Loading...</h2>
                    <p>If this message persist, the server does not support exporting groups for live map purposes</p>
                </div>
            )
        }

        const groupLayers = renderLayers(
            this.state.currentGroups,
            (group: Group) => this.groupClickHandler(group),
            { showAirDefenses, showArmor, showBlue, showGround });
        const heatmapLayer = renderHeatmap(this.state.currentGroups);
        const routeLayer = renderRoute(route);
        // const chartSources = renderSources();
        const chartLayers = renderChartLayers();

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
                    onStyleLoad={(map) => this.mapLoaded(map)}
                    onClick={(map, event) => this.mapMouseClick(map, event)}
                    containerStyle={{
                        width: "100%",
                        height: "100%"
                    }}>
                    {showApproachChart ? chartLayers : undefined}
                    {showHeatmap ? heatmapLayer : undefined}
                    {groupLayers}
                    {routeLayer}
                    {/* noop */}
                    {popup}
                </Mapbox>
                <FilterBox
                    showAirDefenses={showAirDefenses}
                    showArmor={showArmor}
                    showBlue={showBlue}
                    showGround={showGround}
                    showHeatmap={showHeatmap}
                    onFilterSelection={this.onFilterSelection}
                />
                {cursorCoordinates}
            </div>
        )
    }
}
